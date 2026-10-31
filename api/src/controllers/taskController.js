const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');
const TaskActivity = require('../models/TaskActivity');
const EmailLog = require('../models/EmailLog');
const { logActivity } = require('../services/taskService');
const { sendEmail } = require('../services/emailService');
const { createBulkNotifications } = require('../services/notificationService');
const {
  generateDueDateChangedEmail,
  generateTaskCompletedEmail,
} = require('../utils/emailTemplates');
const User = require('../models/User');

// GET /api/tasks
const getTasks = async (req, res, next) => {
  try {
    const { scope, status, priority, q, assigneeId, sortBy = 'createdAt', order = 'desc', page = 1, limit = 20 } = req.query;
    const userId = req.user._id;

    let query = {};

    if (scope === 'created' || scope === 'mine') {
      query.createdBy = userId;
    } else if (scope === 'assigned') {
      query.assigneeIds = userId;
    } else if (scope === 'shared') {
      const shares = await TaskShare.find({ userId }).distinct('taskId');
      query._id = { $in: shares };
    } else {
      // Default: all tasks accessible to the user
      const shares = await TaskShare.find({ userId }).distinct('taskId');
      query.$or = [
        { createdBy: userId },
        { assigneeIds: userId },
        { _id: { $in: shares } },
      ];
    }

    if (status) query.status = status;
    if (priority) query.priority = priority;
    if (assigneeId) query.assigneeIds = assigneeId;
    if (q) {
      const regex = new RegExp(q, 'i');
      query.$and = [
        ...(query.$and || []),
        { $or: [{ title: regex }, { description: regex }] },
      ];
    }

    const sortOrder = order === 'asc' ? 1 : -1;
    const validSortFields = ['createdAt', 'updatedAt', 'dueDate', 'priority', 'title'];
    const sortField = validSortFields.includes(sortBy) ? sortBy : 'createdAt';

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [tasks, total] = await Promise.all([
      Task.find(query)
        .populate('createdBy', 'fullName email avatarUrl')
        .populate('assigneeIds', 'fullName email avatarUrl')
        .populate('primaryAssigneeId', 'fullName email avatarUrl')
        .sort({ [sortField]: sortOrder })
        .skip(skip)
        .limit(parseInt(limit)),
      Task.countDocuments(query),
    ]);

    return res.json({
      success: true,
      tasks,
      data: {
        tasks,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(total / parseInt(limit)),
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks
const createTask = async (req, res, next) => {
  try {
    const { title, description, startDate, dueDate, priority, status, assigneeIds, primaryAssigneeId } = req.body;

    const task = await Task.create({
      title,
      description,
      startDate,
      dueDate,
      priority,
      status,
      assigneeIds: assigneeIds || [],
      primaryAssigneeId: primaryAssigneeId || null,
      createdBy: req.user._id,
    });

    await logActivity({ taskId: task._id, userId: req.user._id, action: 'created', details: { title } });

    const populated = await Task.findById(task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.status(201).json({ success: true, message: 'Task created.', task: populated, data: { task: populated } });
  } catch (error) {
    next(error);
  }
};

// GET /api/tasks/:id
const getTaskById = async (req, res, next) => {
  try {
    const task = await Task.findById(req.task._id)
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.json({
      success: true,
      task,
      permission: req.taskPermission,
      data: { task, permission: req.taskPermission },
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/tasks/:id
const updateTask = async (req, res, next) => {
  try {
    const allowedFields = ['title', 'description', 'startDate', 'dueDate', 'priority', 'status'];
    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) updates[field] = req.body[field];
    }

    const oldTask = req.task;
    const oldDueDate = oldTask.dueDate;

    const task = await Task.findByIdAndUpdate(oldTask._id, updates, { new: true, runValidators: true })
      .populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    await logActivity({ taskId: task._id, userId: req.user._id, action: 'updated', details: updates });

    // Send emails if dueDate changed
    if (updates.dueDate !== undefined && String(oldDueDate) !== String(updates.dueDate)) {
      const assignees = await User.find({ _id: { $in: task.assigneeIds } });
      for (const assignee of assignees) {
        if (assignee._id.toString() === req.user._id.toString()) continue;
        const { subject, html } = generateDueDateChangedEmail(task, assignee, oldDueDate, task.dueDate);
        await sendEmail({ to: assignee.email, subject, html, taskId: task._id, eventType: 'due_date_changed' });
      }

      // Notifications
      const notifs = task.assigneeIds
        .filter((a) => a._id.toString() !== req.user._id.toString())
        .map((a) => ({
          userId: a._id,
          taskId: task._id,
          type: 'due_date_changed',
          title: 'Due date updated',
          message: `Due date for "${task.title}" has been updated.`,
        }));
      if (notifs.length) await createBulkNotifications(notifs);
    }

    // Send emails if task completed
    if (updates.status === 'completed' && oldTask.status !== 'completed') {
      const assignees = await User.find({ _id: { $in: task.assigneeIds } });
      for (const assignee of assignees) {
        if (assignee._id.toString() === req.user._id.toString()) continue;
        const { subject, html } = generateTaskCompletedEmail(task, assignee, req.user);
        await sendEmail({ to: assignee.email, subject, html, taskId: task._id, eventType: 'task_completed' });
      }
    }

    return res.json({ success: true, message: 'Task updated.', task, data: { task } });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id
const deleteTask = async (req, res, next) => {
  try {
    await Task.findByIdAndDelete(req.task._id);
    await logActivity({ taskId: req.task._id, userId: req.user._id, action: 'deleted', details: { title: req.task.title } });
    return res.json({ success: true, message: 'Task deleted.' });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/status
const updateStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const oldStatus = req.task.status;

    const task = await Task.findByIdAndUpdate(
      req.task._id,
      { status },
      { new: true, runValidators: true }
    ).populate('createdBy', 'fullName email avatarUrl')
      .populate('assigneeIds', 'fullName email avatarUrl');

    await logActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'status_changed',
      details: { from: oldStatus, to: status },
    });

    // Notify and email on completion
    if (status === 'completed' && oldStatus !== 'completed') {
      const assignees = await User.find({ _id: { $in: task.assigneeIds } });
      for (const assignee of assignees) {
        if (assignee._id.toString() === req.user._id.toString()) continue;
        const { subject, html } = generateTaskCompletedEmail(task, assignee, req.user);
        await sendEmail({ to: assignee.email, subject, html, taskId: task._id, eventType: 'task_completed' });
      }

      const notifs = task.assigneeIds
        .filter((a) => a._id.toString() !== req.user._id.toString())
        .map((a) => ({
          userId: a._id,
          taskId: task._id,
          type: 'task_completed',
          title: 'Task completed',
          message: `"${task.title}" has been marked as completed.`,
        }));
      if (notifs.length) await createBulkNotifications(notifs);
    }

    return res.json({ success: true, message: 'Status updated.', task, data: { task } });
  } catch (error) {
    next(error);
  }
};

// GET /api/tasks/:id/activities
const getActivities = async (req, res, next) => {
  try {
    const activities = await TaskActivity.find({ taskId: req.task._id })
      .populate('userId', 'fullName email avatarUrl')
      .sort({ createdAt: -1 })
      .limit(100);

    return res.json({ success: true, data: { activities } });
  } catch (error) {
    next(error);
  }
};

// GET /api/tasks/:id/email-logs
const getEmailLogs = async (req, res, next) => {
  try {
    const logs = await EmailLog.find({ taskId: req.task._id }).sort({ createdAt: -1 });
    return res.json({ success: true, data: { logs } });
  } catch (error) {
    next(error);
  }
};

module.exports = { getTasks, createTask, getTaskById, updateTask, deleteTask, updateStatus, getActivities, getEmailLogs };

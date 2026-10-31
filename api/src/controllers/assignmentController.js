const Task = require('../models/Task');
const User = require('../models/User');
const { sendEmail } = require('../services/emailService');
const { createBulkNotifications } = require('../services/notificationService');
const { logActivity } = require('../services/taskService');
const { generateTaskAssignedEmail } = require('../utils/emailTemplates');

// GET /api/tasks/:id/assignees
const getAssignees = async (req, res, next) => {
  try {
    const task = await Task.findById(req.task._id)
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    return res.json({
      success: true,
      assignees: task.assigneeIds,
      primaryAssigneeId: task.primaryAssigneeId,
      data: {
        assignees: task.assigneeIds,
        primaryAssigneeId: task.primaryAssigneeId,
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks/:id/assignees
const addAssignees = async (req, res, next) => {
  try {
    const { userIds, primaryAssigneeId } = req.body;

    if (!userIds || !Array.isArray(userIds) || userIds.length === 0) {
      return res.status(400).json({ success: false, message: 'userIds array is required.' });
    }

    const users = await User.find({ _id: { $in: userIds } });
    if (users.length !== userIds.length) {
      return res.status(400).json({ success: false, message: 'One or more user IDs are invalid.' });
    }

    const task = req.task;
    const existingIds = task.assigneeIds.map((id) => id.toString());
    const newUserIds = userIds.filter((id) => !existingIds.includes(id));

    const updateData = {
      $addToSet: { assigneeIds: { $each: userIds } },
    };
    if (primaryAssigneeId) updateData.primaryAssigneeId = primaryAssigneeId;

    const updatedTask = await Task.findByIdAndUpdate(task._id, updateData, { new: true })
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    await logActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignees_added',
      details: { addedUserIds: newUserIds },
    });

    // Send emails and notifications to newly added assignees
    const newUsers = users.filter((u) => newUserIds.includes(u._id.toString()));
    for (const assignee of newUsers) {
      const { subject, html } = generateTaskAssignedEmail(task, assignee, req.user);
      await sendEmail({ to: assignee.email, subject, html, taskId: task._id, eventType: 'task_assigned' });
    }

    const notifs = newUsers.map((u) => ({
      userId: u._id,
      taskId: task._id,
      type: 'task_assigned',
      title: 'New task assignment',
      message: `You have been assigned to "${task.title}" by ${req.user.fullName}.`,
    }));
    if (notifs.length) await createBulkNotifications(notifs);

    return res.json({ success: true, message: 'Assignees updated.', task: updatedTask, data: { task: updatedTask } });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/assignees/:userId
const updateAssignee = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { isPrimary } = req.body;

    const task = req.task;
    const isAssigned = task.assigneeIds.map((id) => id.toString()).includes(userId);
    if (!isAssigned) {
      return res.status(404).json({ success: false, message: 'User is not an assignee of this task.' });
    }

    const updateData = {};
    if (isPrimary) {
      updateData.primaryAssigneeId = userId;
    } else if (isPrimary === false && task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      updateData.primaryAssigneeId = null;
    }

    const updatedTask = await Task.findByIdAndUpdate(task._id, updateData, { new: true })
      .populate('assigneeIds', 'fullName email avatarUrl')
      .populate('primaryAssigneeId', 'fullName email avatarUrl');

    await logActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignee_updated',
      details: { targetUserId: userId, isPrimary },
    });

    return res.json({ success: true, message: 'Assignee role updated.', task: updatedTask, data: { task: updatedTask } });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id/assignees/:userId
const removeAssignee = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const task = req.task;

    const isAssigned = task.assigneeIds.map((id) => id.toString()).includes(userId);
    if (!isAssigned) {
      return res.status(404).json({ success: false, message: 'User is not an assignee of this task.' });
    }

    const updateData = {
      $pull: { assigneeIds: userId },
    };
    if (task.primaryAssigneeId && task.primaryAssigneeId.toString() === userId) {
      updateData.primaryAssigneeId = null;
    }

    await Task.findByIdAndUpdate(task._id, updateData);
    await logActivity({
      taskId: task._id,
      userId: req.user._id,
      action: 'assignee_removed',
      details: { removedUserId: userId },
    });

    return res.json({ success: true, message: 'Assignee removed.' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getAssignees, addAssignees, updateAssignee, removeAssignee };

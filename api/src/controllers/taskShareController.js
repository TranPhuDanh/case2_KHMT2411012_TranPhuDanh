const TaskShare = require('../models/TaskShare');
const User = require('../models/User');
const { sendEmail } = require('../services/emailService');
const { createBulkNotifications } = require('../services/notificationService');
const { logActivity } = require('../services/taskService');
const { generateTaskSharedEmail } = require('../utils/emailTemplates');

// GET /api/tasks/:id/shares
const getShares = async (req, res, next) => {
  try {
    const shares = await TaskShare.find({ taskId: req.task._id })
      .populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email avatarUrl');

    return res.json({ success: true, data: { shares } });
  } catch (error) {
    next(error);
  }
};

// POST /api/tasks/:id/shares
const createShare = async (req, res, next) => {
  try {
    const { userId, permission = 'viewer' } = req.body;

    if (!userId) {
      return res.status(400).json({ success: false, message: 'userId is required.' });
    }

    if (!['viewer', 'editor'].includes(permission)) {
      return res.status(400).json({ success: false, message: 'Permission must be viewer or editor.' });
    }

    const targetUser = await User.findById(userId);
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }

    // Cannot share with owner
    if (req.task.createdBy.toString() === userId) {
      return res.status(400).json({ success: false, message: 'Cannot share task with its owner.' });
    }

    // Upsert share
    const share = await TaskShare.findOneAndUpdate(
      { taskId: req.task._id, userId },
      { permission, sharedBy: req.user._id },
      { upsert: true, new: true }
    ).populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email avatarUrl');

    await logActivity({
      taskId: req.task._id,
      userId: req.user._id,
      action: 'task_shared',
      details: { sharedWith: userId, permission },
    });

    // Email + notification
    const { subject, html } = generateTaskSharedEmail(req.task, targetUser, req.user, permission);
    await sendEmail({ to: targetUser.email, subject, html, taskId: req.task._id, eventType: 'task_shared' });

    await createBulkNotifications([{
      userId: targetUser._id,
      taskId: req.task._id,
      type: 'task_shared',
      title: 'Task shared with you',
      message: `${req.user.fullName} shared "${req.task.title}" with you as ${permission}.`,
    }]);

    return res.status(201).json({ success: true, message: 'Task shared.', data: { share } });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/tasks/:id/shares/:shareId
const updateShare = async (req, res, next) => {
  try {
    const { permission } = req.body;

    if (!['viewer', 'editor'].includes(permission)) {
      return res.status(400).json({ success: false, message: 'Permission must be viewer or editor.' });
    }

    const share = await TaskShare.findOneAndUpdate(
      { _id: req.params.shareId, taskId: req.task._id },
      { permission },
      { new: true }
    ).populate('userId', 'fullName email avatarUrl')
      .populate('sharedBy', 'fullName email avatarUrl');

    if (!share) {
      return res.status(404).json({ success: false, message: 'Share not found.' });
    }

    await logActivity({
      taskId: req.task._id,
      userId: req.user._id,
      action: 'share_permission_updated',
      details: { shareId: req.params.shareId, newPermission: permission },
    });

    return res.json({ success: true, message: 'Permission updated.', data: { share } });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/tasks/:id/shares/:shareId
const deleteShare = async (req, res, next) => {
  try {
    const share = await TaskShare.findOneAndDelete({ _id: req.params.shareId, taskId: req.task._id });
    if (!share) {
      return res.status(404).json({ success: false, message: 'Share not found.' });
    }

    await logActivity({
      taskId: req.task._id,
      userId: req.user._id,
      action: 'share_revoked',
      details: { shareId: req.params.shareId },
    });

    return res.json({ success: true, message: 'Share revoked.' });
  } catch (error) {
    next(error);
  }
};

module.exports = { getShares, createShare, updateShare, deleteShare };

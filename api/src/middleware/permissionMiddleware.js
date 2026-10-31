const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

/**
 * Load task and check if current user has at least viewer access.
 * Sets req.task and req.taskPermission ('owner'|'editor'|'viewer')
 */
const loadTaskWithPermission = async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ success: false, message: 'Task not found.' });
    }

    const userId = req.user._id.toString();
    const isOwner = task.createdBy.toString() === userId;
    const isAssignee = task.assigneeIds.map((id) => id.toString()).includes(userId);

    let permission = null;

    if (isOwner) {
      permission = 'owner';
    } else if (isAssignee) {
      permission = 'assignee';
    } else {
      const share = await TaskShare.findOne({ taskId: task._id, userId: req.user._id });
      if (share) {
        permission = share.permission; // 'editor' | 'viewer'
      }
    }

    if (!permission) {
      return res.status(403).json({ success: false, message: 'Access denied. You do not have permission to access this task.' });
    }

    req.task = task;
    req.taskPermission = permission;
    next();
  } catch (error) {
    next(error);
  }
};

/**
 * Require owner or editor permission
 */
const requireEditorOrOwner = (req, res, next) => {
  if (req.taskPermission === 'owner' || req.taskPermission === 'editor' || req.taskPermission === 'assignee') {
    return next();
  }
  return res.status(403).json({ success: false, message: 'Access denied. Editor or owner permission required.' });
};

/**
 * Require owner permission only
 */
const requireOwner = (req, res, next) => {
  if (req.taskPermission === 'owner') {
    return next();
  }
  return res.status(403).json({ success: false, message: 'Access denied. Only the task owner can perform this action.' });
};

module.exports = { loadTaskWithPermission, requireEditorOrOwner, requireOwner };

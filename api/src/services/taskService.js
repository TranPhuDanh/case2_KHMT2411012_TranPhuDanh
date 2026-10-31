const TaskActivity = require('../models/TaskActivity');

/**
 * Log a task activity
 */
const logActivity = async ({ taskId, userId, action, details = {} }) => {
  return TaskActivity.create({ taskId, userId, action, details });
};

module.exports = { logActivity };

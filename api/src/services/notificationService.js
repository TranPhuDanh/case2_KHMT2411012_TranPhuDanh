const Notification = require('../models/Notification');

/**
 * Create a notification for a user
 */
const createNotification = async ({ userId, taskId = null, type, title, message }) => {
  const notification = await Notification.create({
    userId,
    taskId,
    type,
    title,
    message,
  });
  return notification;
};

/**
 * Create notifications for multiple users
 */
const createBulkNotifications = async (notifications) => {
  return Notification.insertMany(notifications);
};

module.exports = { createNotification, createBulkNotifications };

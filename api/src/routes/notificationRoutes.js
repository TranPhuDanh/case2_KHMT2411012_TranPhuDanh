const express = require('express');
const router = express.Router();
const { getNotifications, getUnreadCount, markAsRead, markAllAsRead } = require('../controllers/notificationController');
const { authenticate } = require('../middleware/authMiddleware');

router.get('/', authenticate, getNotifications);
router.get('/unread-count', authenticate, getUnreadCount);
router.patch('/read-all', authenticate, markAllAsRead);
router.patch('/:id/read', authenticate, markAsRead);

module.exports = router;

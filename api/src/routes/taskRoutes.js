const express = require('express');
const router = express.Router();
const {
  getTasks,
  createTask,
  getTaskById,
  updateTask,
  deleteTask,
  updateStatus,
  getActivities,
  getEmailLogs,
  sendTaskEmail,
} = require('../controllers/taskController');
const { authenticate } = require('../middleware/authMiddleware');
const { loadTaskWithPermission, requireEditorOrOwner, requireOwner } = require('../middleware/permissionMiddleware');
const { validate } = require('../middleware/validateMiddleware');
const { createTaskValidator, updateTaskValidator, updateStatusValidator } = require('../validators/taskValidator');

router.get('/', authenticate, getTasks);
router.post('/', authenticate, createTaskValidator, validate, createTask);

router.get('/:id', authenticate, loadTaskWithPermission, getTaskById);
router.put('/:id', authenticate, loadTaskWithPermission, requireOwner, updateTaskValidator, validate, updateTask);
router.delete('/:id', authenticate, loadTaskWithPermission, requireOwner, deleteTask);
router.patch('/:id/status', authenticate, loadTaskWithPermission, requireEditorOrOwner, updateStatusValidator, validate, updateStatus);
router.get('/:id/activities', authenticate, loadTaskWithPermission, getActivities);
router.get('/:id/email-logs', authenticate, loadTaskWithPermission, getEmailLogs);
router.post('/:id/send-email', authenticate, loadTaskWithPermission, sendTaskEmail);

module.exports = router;

const express = require('express');
const router = express.Router({ mergeParams: true });
const { getAssignees, addAssignees, updateAssignee, removeAssignee } = require('../controllers/assignmentController');
const { authenticate } = require('../middleware/authMiddleware');
const { loadTaskWithPermission, requireOwner } = require('../middleware/permissionMiddleware');

router.get('/', authenticate, loadTaskWithPermission, getAssignees);
router.post('/', authenticate, loadTaskWithPermission, requireOwner, addAssignees);
router.patch('/:userId', authenticate, loadTaskWithPermission, requireOwner, updateAssignee);
router.delete('/:userId', authenticate, loadTaskWithPermission, requireOwner, removeAssignee);

module.exports = router;

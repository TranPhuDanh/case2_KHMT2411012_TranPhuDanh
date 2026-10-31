const express = require('express');
const router = express.Router({ mergeParams: true });
const { getAssignees, addAssignees, updateAssignee, removeAssignee } = require('../controllers/assignmentController');
const { authenticate } = require('../middleware/authMiddleware');
const { loadTaskWithPermission, requireEditorOrOwner, requireOwner } = require('../middleware/permissionMiddleware');

router.get('/', authenticate, loadTaskWithPermission, getAssignees);
router.post('/', authenticate, loadTaskWithPermission, requireEditorOrOwner, addAssignees);
router.patch('/:userId', authenticate, loadTaskWithPermission, requireEditorOrOwner, updateAssignee);
router.put('/:userId', authenticate, loadTaskWithPermission, requireEditorOrOwner, updateAssignee);
router.delete('/:userId', authenticate, loadTaskWithPermission, requireEditorOrOwner, removeAssignee);

module.exports = router;

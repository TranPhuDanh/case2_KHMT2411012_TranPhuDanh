const express = require('express');
const router = express.Router({ mergeParams: true });
const { getShares, createShare, updateShare, deleteShare } = require('../controllers/taskShareController');
const { authenticate } = require('../middleware/authMiddleware');
const { loadTaskWithPermission, requireOwner } = require('../middleware/permissionMiddleware');

router.get('/', authenticate, loadTaskWithPermission, getShares);
router.post('/', authenticate, loadTaskWithPermission, requireOwner, createShare);
router.patch('/:shareId', authenticate, loadTaskWithPermission, requireOwner, updateShare);
router.put('/:shareId', authenticate, loadTaskWithPermission, requireOwner, updateShare);
router.delete('/:shareId', authenticate, loadTaskWithPermission, requireOwner, deleteShare);

module.exports = router;

const express = require('express');
const router = express.Router();
const { searchUsers, getUserById } = require('../controllers/userController');
const { authenticate } = require('../middleware/authMiddleware');

router.get('/search', authenticate, searchUsers);
router.get('/:id', authenticate, getUserById);

module.exports = router;

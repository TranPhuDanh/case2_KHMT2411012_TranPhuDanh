const express = require('express');
const router = express.Router();
const { register, login, getMe, updateMe, changePassword } = require('../controllers/authController');
const { authenticate } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validateMiddleware');
const {
  registerValidator,
  loginValidator,
  updateProfileValidator,
  changePasswordValidator,
} = require('../validators/authValidator');

router.post('/register', registerValidator, validate, register);
router.post('/login', loginValidator, validate, login);
router.get('/me', authenticate, getMe);
router.put('/me', authenticate, updateProfileValidator, validate, updateMe);
router.put('/change-password', authenticate, changePasswordValidator, validate, changePassword);

module.exports = router;

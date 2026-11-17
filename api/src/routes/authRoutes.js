const express = require('express');
const router = express.Router();
const {
  register,
  login,
  logout,
  getMe,
  updateMe,
  changePassword,
  getLoginHistory,
} = require('../controllers/authController');
const { authenticate } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validateMiddleware');
const {
  registerValidator,
  loginValidator,
  updateProfileValidator,
  changePasswordValidator,
} = require('../validators/authValidator');

const optionalAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authenticate(req, res, (err) => {
      // If error (e.g. token expired), continue anyway so logout with body email works
      next();
    });
  }
  next();
};

router.post('/register', registerValidator, validate, register);
router.post('/login', loginValidator, validate, login);
router.post('/logout', optionalAuth, logout);
router.get('/me', authenticate, getMe);
router.get('/profile', authenticate, getMe);
router.get('/login-history', authenticate, getLoginHistory);
router.put('/me', authenticate, updateProfileValidator, validate, updateMe);
router.put('/profile', authenticate, updateProfileValidator, validate, updateMe);
router.put('/change-password', authenticate, changePasswordValidator, validate, changePassword);

module.exports = router;

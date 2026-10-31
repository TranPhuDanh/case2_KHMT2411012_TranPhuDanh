const { body } = require('express-validator');

const registerValidator = [
  body('fullName')
    .trim()
    .notEmpty().withMessage('Full name is required')
    .isLength({ max: 100 }).withMessage('Full name cannot exceed 100 characters'),
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Please enter a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Password is required')
    .isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
];

const loginValidator = [
  body('email')
    .trim()
    .notEmpty().withMessage('Email is required')
    .isEmail().withMessage('Please enter a valid email')
    .normalizeEmail(),
  body('password')
    .notEmpty().withMessage('Password is required'),
];

const updateProfileValidator = [
  body('fullName')
    .optional()
    .trim()
    .notEmpty().withMessage('Full name cannot be empty')
    .isLength({ max: 100 }).withMessage('Full name cannot exceed 100 characters'),
  body('avatarUrl')
    .optional()
    .isURL().withMessage('Avatar URL must be a valid URL'),
];

const changePasswordValidator = [
  body('currentPassword')
    .notEmpty().withMessage('Current password is required'),
  body('newPassword')
    .notEmpty().withMessage('New password is required')
    .isLength({ min: 6 }).withMessage('New password must be at least 6 characters'),
];

module.exports = {
  registerValidator,
  loginValidator,
  updateProfileValidator,
  changePasswordValidator,
};

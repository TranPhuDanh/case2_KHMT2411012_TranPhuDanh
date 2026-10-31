const { body } = require('express-validator');

const createTaskValidator = [
  body('title')
    .trim()
    .notEmpty().withMessage('Title is required')
    .isLength({ max: 200 }).withMessage('Title cannot exceed 200 characters'),
  body('description')
    .optional()
    .isLength({ max: 2000 }).withMessage('Description cannot exceed 2000 characters'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high']).withMessage('Priority must be low, medium, or high'),
  body('status')
    .optional()
    .isIn(['todo', 'in_progress', 'completed']).withMessage('Status must be todo, in_progress, or completed'),
  body('startDate')
    .optional()
    .isISO8601().withMessage('Start date must be a valid date'),
  body('dueDate')
    .optional()
    .isISO8601().withMessage('Due date must be a valid date'),
];

const updateTaskValidator = [
  body('title')
    .optional()
    .trim()
    .notEmpty().withMessage('Title cannot be empty')
    .isLength({ max: 200 }).withMessage('Title cannot exceed 200 characters'),
  body('description')
    .optional()
    .isLength({ max: 2000 }).withMessage('Description cannot exceed 2000 characters'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high']).withMessage('Priority must be low, medium, or high'),
  body('status')
    .optional()
    .isIn(['todo', 'in_progress', 'completed']).withMessage('Status must be todo, in_progress, or completed'),
  body('startDate')
    .optional({ nullable: true })
    .isISO8601().withMessage('Start date must be a valid date'),
  body('dueDate')
    .optional({ nullable: true })
    .isISO8601().withMessage('Due date must be a valid date'),
];

const updateStatusValidator = [
  body('status')
    .notEmpty().withMessage('Status is required')
    .isIn(['todo', 'in_progress', 'completed']).withMessage('Status must be todo, in_progress, or completed'),
];

module.exports = { createTaskValidator, updateTaskValidator, updateStatusValidator };

const express = require('express');
const router = express.Router();
const EmailLog = require('../models/EmailLog');
const { retryEmail } = require('../services/emailService');
const { authenticate } = require('../middleware/authMiddleware');

// POST /api/email-logs/:id/retry
router.post('/:id/retry', authenticate, async (req, res, next) => {
  try {
    const result = await retryEmail(req.params.id);
    return res.json({ success: true, message: 'Email retry successful.', data: { log: result.log } });
  } catch (error) {
    if (error.message === 'Email log not found') {
      return res.status(404).json({ success: false, message: error.message });
    }
    return res.status(400).json({ success: false, message: error.message });
  }
});

module.exports = router;

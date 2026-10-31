const { createTransporter } = require('../config/email');
const EmailLog = require('../models/EmailLog');

/**
 * Send an email and log the attempt
 */
const sendEmail = async ({ to, subject, html, taskId = null, eventType }) => {
  // Create log entry with pending status
  const log = await EmailLog.create({
    taskId,
    recipientEmail: to,
    eventType,
    subject,
    status: 'pending',
    attempts: 0,
  });

  try {
    const transporter = createTransporter();
    await transporter.sendMail({
      from: process.env.SMTP_FROM,
      to,
      subject,
      html,
    });

    log.status = 'sent';
    log.sentAt = new Date();
    log.attempts = 1;
    await log.save();

    return { success: true, logId: log._id };
  } catch (error) {
    log.status = 'failed';
    log.attempts = 1;
    log.errorMessage = error.message;
    await log.save();

    console.error(`Email send failed to ${to}:`, error.message);
    return { success: false, logId: log._id, error: error.message };
  }
};

/**
 * Retry a failed email
 */
const retryEmail = async (logId) => {
  const log = await EmailLog.findById(logId);
  if (!log) {
    throw new Error('Email log not found');
  }
  if (log.status === 'sent') {
    throw new Error('Email already sent successfully');
  }

  log.attempts += 1;
  log.status = 'pending';

  try {
    const transporter = createTransporter();
    await transporter.sendMail({
      from: process.env.SMTP_FROM,
      to: log.recipientEmail,
      subject: log.subject,
    });

    log.status = 'sent';
    log.sentAt = new Date();
    log.errorMessage = null;
    await log.save();

    return { success: true, log };
  } catch (error) {
    log.status = 'failed';
    log.errorMessage = error.message;
    await log.save();

    throw new Error(`Retry failed: ${error.message}`);
  }
};

module.exports = { sendEmail, retryEmail };

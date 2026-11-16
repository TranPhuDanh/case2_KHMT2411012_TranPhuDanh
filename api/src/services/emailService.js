const nodemailer = require('nodemailer');
const { createTransporter } = require('../config/email');
const EmailLog = require('../models/EmailLog');

let etherealTransporter = null;

const getEtherealTransporter = async () => {
  if (!etherealTransporter) {
    const testAccount = await nodemailer.createTestAccount();
    etherealTransporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
    });
  }
  return etherealTransporter;
};

/**
 * Send an email and log the attempt in MongoDB
 */
const sendEmail = async ({ to, subject, html, text, taskId = null, eventType }) => {
  // Create log entry with pending status in MongoDB
  const log = await EmailLog.create({
    taskId,
    recipientEmail: to,
    eventType,
    subject,
    status: 'pending',
    attempts: 0,
  });

  const fromSender = process.env.SMTP_FROM || '"CASE STUDY 2" <tpdanh.mucdichcanhan@gmail.com>';
  const plainText = text || (html ? html.replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim() : subject);

  // First try: Attempt using configured SMTP (e.g. Gmail)
  try {
    const transporter = createTransporter();
    const info = await transporter.sendMail({
      from: fromSender,
      to,
      subject,
      text: plainText,
      html,
    });

    log.status = 'sent';
    log.sentAt = new Date();
    log.attempts = 1;
    await log.save();

    console.log(`[EmailService] Đã gửi email thành công qua SMTP đến: ${to} (Chủ đề: ${subject})`);
    return { success: true, logId: log._id };
  } catch (error) {
    // If SMTP fails (e.g. demo credentials test@gmail.com), deliver via Ethereal to generate live preview
    console.warn(`[EmailService] SMTP chưa xác thực (${error.message}). Tự động gửi qua Ethereal Email để tạo link xem thư trực tuyến...`);
    try {
      const fallbackTransporter = await getEtherealTransporter();
      const info = await fallbackTransporter.sendMail({
        from: fromSender,
        to,
        subject,
        html,
      });

      const previewUrl = nodemailer.getTestMessageUrl(info);
      log.status = 'sent';
      log.sentAt = new Date();
      log.attempts = 1;
      log.previewUrl = previewUrl;
      await log.save();

      console.log(`[EmailService] Đã tạo thư gửi đến ${to} thành công!`);
      console.log(`[EmailService] >> BẤM VÀO ĐÂY ĐỂ XEM THƯ TRỰC TUYẾN: ${previewUrl}`);
      return { success: true, logId: log._id, previewUrl };
    } catch (fallbackError) {
      log.status = 'failed';
      log.attempts = 1;
      log.errorMessage = fallbackError.message;
      await log.save();

      console.error(`[EmailService] Gửi email thất bại đến ${to}:`, fallbackError.message);
      return { success: false, logId: log._id, error: fallbackError.message };
    }
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
      from: process.env.SMTP_FROM || '"CASE STUDY 2" <no-reply@student.ctuet.edu.vn>',
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

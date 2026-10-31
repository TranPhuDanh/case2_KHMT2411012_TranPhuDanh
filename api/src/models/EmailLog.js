const mongoose = require('mongoose');

const emailLogSchema = new mongoose.Schema(
  {
    taskId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Task',
      default: null,
    },
    recipientEmail: {
      type: String,
      required: true,
    },
    eventType: {
      type: String,
      required: true,
    },
    subject: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      enum: ['pending', 'sent', 'failed'],
      default: 'pending',
    },
    attempts: {
      type: Number,
      default: 0,
    },
    errorMessage: {
      type: String,
      default: null,
    },
    sentAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

emailLogSchema.index({ taskId: 1 });
emailLogSchema.index({ status: 1 });
emailLogSchema.index({ recipientEmail: 1 });

module.exports = mongoose.model('EmailLog', emailLogSchema);

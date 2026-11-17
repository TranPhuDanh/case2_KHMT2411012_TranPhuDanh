const mongoose = require('mongoose');

const loginHistorySchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
    },
    fullName: {
      type: String,
      required: true,
    },
    ipAddress: {
      type: String,
      default: '127.0.0.1',
    },
    clientInfo: {
      type: String,
      default: 'CASE STUDY 2 - Flutter App',
    },
    loginAt: {
      type: Date,
      default: Date.now,
    },
    status: {
      type: String,
      enum: ['success', 'failed'],
      default: 'success',
    },
  },
  {
    timestamps: true,
  }
);

loginHistorySchema.index({ userId: 1, loginAt: -1 });
loginHistorySchema.index({ email: 1, loginAt: -1 });

module.exports = mongoose.model('LoginHistory', loginHistorySchema);

require('dotenv').config();
const app = require('./app');
const connectDB = require('./config/database');
const cron = require('node-cron');
const Task = require('./models/Task');
const User = require('./models/User');
const TaskShare = require('./models/TaskShare');
const { sendEmail } = require('./services/emailService');
const { generateDeadlineReminderEmail } = require('./utils/emailTemplates');

const PORT = process.env.PORT || 3000;

// Connect to database and start server
const startServer = async () => {
  await connectDB();

  // Scheduled task: Send deadline reminders every hour for tasks due in next 24 hours
  cron.schedule('0 * * * *', async () => {
    console.log('[CRON] Running deadline reminder job...');
    try {
      const now = new Date();
      const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
      const in25h = new Date(now.getTime() + 25 * 60 * 60 * 1000);

      // Find tasks due between now+24h and now+25h (1-hour window to avoid duplicate emails)
      const tasks = await Task.find({
        dueDate: { $gte: in24h, $lt: in25h },
        status: { $ne: 'completed' },
      }).populate('assigneeIds');

      for (const task of tasks) {
        for (const assignee of task.assigneeIds) {
          const { subject, html } = generateDeadlineReminderEmail(task, assignee);
          await sendEmail({
            to: assignee.email,
            subject,
            html,
            taskId: task._id,
            eventType: 'deadline_reminder',
          });
          console.log(`[CRON] Sent deadline reminder to ${assignee.email} for task: ${task.title}`);
        }
      }

      console.log(`[CRON] Deadline reminder job completed. Processed ${tasks.length} tasks.`);
    } catch (error) {
      console.error('[CRON] Deadline reminder job failed:', error.message);
    }
  });

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
    console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  });
};

startServer().catch((error) => {
  console.error('Failed to start server:', error);
  process.exit(1);
});

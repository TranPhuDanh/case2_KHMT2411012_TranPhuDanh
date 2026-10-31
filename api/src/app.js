const express = require('express');
const cors = require('cors');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const taskRoutes = require('./routes/taskRoutes');
const assignmentRoutes = require('./routes/assignmentRoutes');
const taskShareRoutes = require('./routes/taskShareRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const statisticsRoutes = require('./routes/statisticsRoutes');
const emailLogRoutes = require('./routes/emailLogRoutes');
const { errorHandler, notFound } = require('./middleware/errorMiddleware');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ success: true, message: 'Task Manager API is running.', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/tasks/:id/assignees', assignmentRoutes);
app.use('/api/tasks/:id/shares', taskShareRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/statistics', statisticsRoutes);
app.use('/api/email-logs', emailLogRoutes);

// Not found
app.use(notFound);

// Error handler
app.use(errorHandler);

module.exports = app;

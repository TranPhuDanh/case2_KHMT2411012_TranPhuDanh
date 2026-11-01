const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/taskmanager';
  try {
    const conn = await mongoose.connect(uri, { serverSelectionTimeoutMS: 2000 });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.warn(`Local MongoDB at ${uri} unavailable (${error.message}).`);
    console.log('Starting Embedded In-Memory MongoDB Server...');
    try {
      const { MongoMemoryServer } = require('mongodb-memory-server');
      const mongod = await MongoMemoryServer.create();
      const inMemoryUri = mongod.getUri();
      const conn = await mongoose.connect(inMemoryUri);
      console.log(`Embedded MongoDB Connected: ${inMemoryUri}`);

      // Auto-seed initial data
      const User = require('../models/User');
      const count = await User.countDocuments();
      if (count === 0) {
        console.log('Seeding initial mock data for testing...');
        const bcrypt = require('bcryptjs');
        const Task = require('../models/Task');
        const Notification = require('../models/Notification');
        const passwordHash = await bcrypt.hash('123456', 10);
        const users = await User.create([
          { fullName: 'Trần Phú Danh', email: 'danh@example.com', passwordHash },
          { fullName: 'Nguyễn Thị Lan', email: 'lan@example.com', passwordHash },
          { fullName: 'Lê Văn Tuấn', email: 'tuan@example.com', passwordHash },
        ]);
        const now = new Date();
        const task1 = await Task.create({
          title: 'Thiết kế giao diện Task Manager',
          description: 'Thiết kế toàn bộ màn hình theo yêu cầu Case Study 2',
          createdBy: users[0]._id,
          assigneeIds: [users[0]._id, users[1]._id],
          primaryAssigneeId: users[0]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000),
          priority: 'high',
          status: 'in_progress',
        });
        await Task.create({
          title: 'Xây dựng REST API Backend',
          description: 'Viết API cho Task, User, Notification, Share, Statistics',
          createdBy: users[0]._id,
          assigneeIds: [users[0]._id],
          primaryAssigneeId: users[0]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000),
          priority: 'high',
          status: 'completed',
        });
        await Task.create({
          title: 'Viết tài liệu báo cáo và kiểm thử',
          description: 'Hoàn thành báo cáo đồ án Case Study 2',
          createdBy: users[0]._id,
          assigneeIds: [users[1]._id, users[2]._id],
          primaryAssigneeId: users[1]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000),
          priority: 'medium',
          status: 'todo',
        });

        // Add mock notification
        await Notification.create({
          userId: users[0]._id,
          taskId: task1._id,
          type: 'task_assigned',
          title: 'Bạn được giao công việc mới',
          message: 'Bạn đã được chỉ định vào công việc: Thiết kế giao diện Task Manager',
          isRead: false,
        });

        console.log('Initial mock data seeded: 3 users, 3 tasks, 1 notification.');
        console.log('Account login test: danh@example.com / 123456');
      }
    } catch (inMemError) {
      console.error('Failed to start Embedded MongoDB:', inMemError.message);
      process.exit(1);
    }
  }
};

module.exports = connectDB;

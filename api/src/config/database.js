const mongoose = require('mongoose');

const connectDB = async () => {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/taskmanager';
  try {
    const conn = await mongoose.connect(uri, { serverSelectionTimeoutMS: 3000 });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.warn(`MongoDB at ${uri} unavailable (${error.message}).`);
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
        const passwordHash = await bcrypt.hash('Danh_123', 10);
        const users = await User.create([
          { fullName: 'TPDanh', email: 'tpdanhkhmt2411012@student.ctuet.edu.vn', passwordHash },
          { fullName: 'Trần Phú Danh', email: 'danh@example.com', passwordHash },
          { fullName: 'Nguyễn Thị Lan', email: 'lan@example.com', passwordHash },
          { fullName: 'Lê Văn Tuấn', email: 'tuan@example.com', passwordHash },
        ]);
        const now = new Date();
        const task1 = await Task.create({
          title: 'Ngyngay',
          description: 'Công việc quan trọng cần hoàn thành đúng hạn',
          createdBy: users[0]._id,
          assigneeIds: [users[0]._id],
          primaryAssigneeId: users[0]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 28 * 24 * 60 * 60 * 1000),
          priority: 'high',
          status: 'in_progress',
        });
        await Task.create({
          title: 'Xây dựng REST API Backend Node.js',
          description: 'Viết API cho Task, User, Notification, Share, Statistics',
          createdBy: users[1]._id,
          assigneeIds: [users[0]._id, users[1]._id],
          primaryAssigneeId: users[0]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000),
          priority: 'high',
          status: 'completed',
        });
        await Task.create({
          title: 'Thiết kế giao diện Flutter Buổi 1',
          description: 'Thiết kế toàn bộ màn hình theo yêu cầu Case Study 2',
          createdBy: users[2]._id,
          assigneeIds: [users[0]._id, users[2]._id],
          primaryAssigneeId: users[2]._id,
          startDate: now,
          dueDate: new Date(now.getTime() + 2 * 24 * 60 * 60 * 1000),
          priority: 'high',
          status: 'in_progress',
        });

        // Add 4 notifications for TPDanh
        await Notification.create([
          {
            userId: users[0]._id,
            taskId: task1._id,
            type: 'task_created',
            title: 'Tạo công việc mới thành công',
            message: 'Bạn đã tạo công việc "Ngyngay" thành công. Mức độ ưu tiên: Cao.',
            isRead: false,
          },
          {
            userId: users[0]._id,
            taskId: task1._id,
            type: 'task_assigned',
            title: 'Bạn được giao công việc mới',
            message: 'Trần Phú Danh đã giao công việc "Xây dựng REST API Backend Node.js" cho bạn phụ trách.',
            isRead: false,
          },
          {
            userId: users[0]._id,
            taskId: task1._id,
            type: 'task_shared',
            title: 'Công việc được chia sẻ với bạn',
            message: 'Nguyễn Thị Lan đã chia sẻ công việc "Thiết kế giao diện Flutter Buổi 1" với quyền Chỉnh sửa (Editor).',
            isRead: false,
          },
          {
            userId: users[0]._id,
            taskId: task1._id,
            type: 'deadline_reminder',
            title: 'Nhắc nhở hạn chót công việc',
            message: 'Công việc "Ngyngay" sắp đến hạn hoàn thành vào ngày 29/11/2026.',
            isRead: true,
          },
        ]);

        console.log('Initial mock data seeded: 4 users, 3 tasks, 4 notifications.');
        console.log('Login credentials: tpdanhkhmt2411012@student.ctuet.edu.vn / Danh_123');
      }
    } catch (inMemError) {
      console.error('Failed to start Embedded MongoDB:', inMemError.message);
      process.exit(1);
    }
  }
};

module.exports = connectDB;

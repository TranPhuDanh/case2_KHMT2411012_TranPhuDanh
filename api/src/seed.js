require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const Task = require('./models/Task');
const TaskShare = require('./models/TaskShare');

const seedData = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/taskmanager';
    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB for seeding...');

    // Clear existing test data
    await User.deleteMany({});
    await Task.deleteMany({});
    await TaskShare.deleteMany({});

    console.log('Cleared existing users, tasks, and task_shares.');

    // Create users
    const passwordHash = await bcrypt.hash('123456', 10);
    const users = await User.create([
      {
        fullName: 'Trần Phú Danh',
        email: 'danh@example.com',
        passwordHash,
      },
      {
        fullName: 'Nguyễn Thị Lan',
        email: 'lan@example.com',
        passwordHash,
      },
      {
        fullName: 'Lê Văn Tuấn',
        email: 'tuan@example.com',
        passwordHash,
      },
    ]);

    const [user1, user2, user3] = users;
    console.log(`Created 3 users:
  1. ${user1.fullName} (${user1.email}) - pass: 123456
  2. ${user2.fullName} (${user2.email}) - pass: 123456
  3. ${user3.fullName} (${user3.email}) - pass: 123456`);

    const now = new Date();
    const in1Day = new Date(now.getTime() + 1 * 24 * 60 * 60 * 1000);
    const in3Days = new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000);
    const in5Days = new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000);
    const in7Days = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    // Create sample tasks
    const tasks = await Task.create([
      {
        title: 'Thiết kế giao diện Flutter Buổi 1',
        description: 'Tạo 4 màn hình: Đăng nhập, Đăng ký, Danh sách công việc và Chi tiết công việc kết nối Backend API.',
        createdBy: user1._id,
        assigneeIds: [user1._id, user2._id],
        primaryAssigneeId: user1._id,
        startDate: now,
        dueDate: in3Days,
        priority: 'high',
        status: 'in_progress',
      },
      {
        title: 'Xây dựng REST API Backend Node.js',
        description: 'Tạo User & Task model, API Đăng ký, Đăng nhập, GET /api/tasks và GET /api/tasks/:id.',
        createdBy: user1._id,
        assigneeIds: [user1._id],
        primaryAssigneeId: user1._id,
        startDate: now,
        dueDate: in1Day,
        priority: 'high',
        status: 'completed',
      },
      {
        title: 'Kiểm thử kết nối API giữa Flutter và Backend',
        description: 'Xác thực luồng đăng ký tài khoản mới, đăng nhập lưu JWT token, tải danh sách và chi tiết công việc.',
        createdBy: user2._id,
        assigneeIds: [user1._id, user2._id],
        primaryAssigneeId: user2._id,
        startDate: in1Day,
        dueDate: in5Days,
        priority: 'medium',
        status: 'todo',
      },
      {
        title: 'Chuẩn bị chức năng Giao việc & Phân quyền (Buổi 2)',
        description: 'Nghiên cứu mô hình chia sẻ tài liệu và gán quyền viewer / editor cho các thành viên trong nhóm.',
        createdBy: user3._id,
        assigneeIds: [user3._id],
        primaryAssigneeId: user3._id,
        startDate: in3Days,
        dueDate: in7Days,
        priority: 'low',
        status: 'todo',
      },
    ]);

    // Create a share record so user1 can view task 4
    await TaskShare.create({
      taskId: tasks[3]._id,
      userId: user1._id,
      permission: 'viewer',
      sharedBy: user3._id,
    });

    console.log(`Created ${tasks.length} sample tasks successfully!`);
    await mongoose.disconnect();
    console.log('Seeding completed successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Seeding error:', error);
    process.exit(1);
  }
};

seedData();

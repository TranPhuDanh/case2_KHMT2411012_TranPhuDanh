const mongoose = require('mongoose');
require('dotenv').config();

const Notification = require('./models/Notification');
const EmailLog = require('./models/EmailLog');
const Task = require('./models/Task');
const User = require('./models/User');

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB Atlas');

    const tpDanh = await User.findOne({ email: 'tpdanhkhmt2411012@student.ctuet.edu.vn' });
    if (!tpDanh) {
      console.error('TPDanh user not found!');
      process.exit(1);
    }

    const taskNgy = await Task.findOne({ createdBy: tpDanh._id });
    const otherTask1 = await Task.findOne({ title: /REST API/ });
    const otherTask2 = await Task.findOne({ title: /Flutter/ });

    // Clear existing notifications for TPDanh
    await Notification.deleteMany({ userId: tpDanh._id });

    const notificationsToInsert = [
      {
        userId: tpDanh._id,
        taskId: taskNgy ? taskNgy._id : null,
        type: 'task_created',
        title: 'Tạo công việc mới thành công',
        message: `Bạn đã tạo công việc "${taskNgy ? taskNgy.title : 'Ngyngay'}" thành công. Mức độ ưu tiên: Cao.`,
        isRead: false,
        createdAt: new Date(),
      },
      {
        userId: tpDanh._id,
        taskId: otherTask1 ? otherTask1._id : null,
        type: 'task_assigned',
        title: 'Bạn được giao công việc mới',
        message: 'Trần Phú Danh đã giao công việc "Xây dựng REST API Backend Node.js" cho bạn phụ trách.',
        isRead: false,
        createdAt: new Date(Date.now() - 3600000),
      },
      {
        userId: tpDanh._id,
        taskId: otherTask2 ? otherTask2._id : null,
        type: 'task_shared',
        title: 'Công việc được chia sẻ với bạn',
        message: 'Nguyễn Thị Lan đã chia sẻ công việc "Thiết kế giao diện Flutter Buổi 1" với quyền Chỉnh sửa (Editor).',
        isRead: false,
        createdAt: new Date(Date.now() - 7200000),
      },
      {
        userId: tpDanh._id,
        taskId: taskNgy ? taskNgy._id : null,
        type: 'deadline_reminder',
        title: 'Nhắc nhở hạn chót công việc',
        message: `Công việc "${taskNgy ? taskNgy.title : 'Ngyngay'}" sắp đến hạn hoàn thành vào ngày 29/11/2026.`,
        isRead: true,
        createdAt: new Date(Date.now() - 86400000),
      },
    ];

    await Notification.insertMany(notificationsToInsert);
    console.log(`Inserted ${notificationsToInsert.length} notifications for ${tpDanh.email}`);

    // Insert Email Logs for TPDanh
    await EmailLog.deleteMany({ recipientEmail: tpDanh.email });
    await EmailLog.insertMany([
      {
        taskId: taskNgy ? taskNgy._id : null,
        recipientEmail: tpDanh.email,
        eventType: 'task_created',
        subject: `[Task Manager] Bạn đã tạo công việc mới: ${taskNgy ? taskNgy.title : 'Ngyngay'}`,
        status: 'sent',
        attempts: 1,
        sentAt: new Date(),
        createdAt: new Date(),
      },
      {
        taskId: otherTask1 ? otherTask1._id : null,
        recipientEmail: tpDanh.email,
        eventType: 'task_assigned',
        subject: '[Task Manager] Bạn được giao công việc: Xây dựng REST API Backend Node.js',
        status: 'sent',
        attempts: 1,
        sentAt: new Date(Date.now() - 3600000),
        createdAt: new Date(Date.now() - 3600000),
      },
    ]);
    console.log(`Inserted email logs for ${tpDanh.email}`);

    process.exit(0);
  } catch (err) {
    console.error('Error seeding notifications:', err);
    process.exit(1);
  }
}

seed();

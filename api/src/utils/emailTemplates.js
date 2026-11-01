const generateTaskAssignedEmail = (task, assignee, assigner) => {
  return {
    subject: `You've been assigned to: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4F46E5;">New Task Assignment</h2>
        <p>Hi <strong>${assignee.fullName}</strong>,</p>
        <p>${assigner.fullName} has assigned you to a task.</p>
        <div style="background: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          ${task.description ? `<p>${task.description}</p>` : ''}
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 4px 0;"><strong>Priority:</strong></td>
              <td>${task.priority}</td>
            </tr>
            <tr>
              <td style="padding: 4px 0;"><strong>Status:</strong></td>
              <td>${task.status}</td>
            </tr>
            ${task.dueDate ? `<tr><td style="padding: 4px 0;"><strong>Due Date:</strong></td><td>${new Date(task.dueDate).toLocaleDateString()}</td></tr>` : ''}
          </table>
        </div>
        <p>Please log in to the Task Manager to view and manage this task.</p>
        <p style="color: #6B7280; font-size: 12px;">This is an automated message from Task Manager.</p>
      </div>
    `,
  };
};

const generateTaskSharedEmail = (task, recipient, sharer, permission) => {
  return {
    subject: `${sharer.fullName} shared a task with you: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #4F46E5;">Task Shared With You</h2>
        <p>Hi <strong>${recipient.fullName}</strong>,</p>
        <p>${sharer.fullName} has shared a task with you as a <strong>${permission}</strong>.</p>
        <div style="background: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          ${task.description ? `<p>${task.description}</p>` : ''}
          <p><strong>Your permission:</strong> ${permission}</p>
        </div>
        <p>Please log in to the Task Manager to view this task.</p>
        <p style="color: #6B7280; font-size: 12px;">This is an automated message from Task Manager.</p>
      </div>
    `,
  };
};

const generateDueDateChangedEmail = (task, assignee, oldDueDate, newDueDate) => {
  return {
    subject: `Due date updated for: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #F59E0B;">Task Due Date Updated</h2>
        <p>Hi <strong>${assignee.fullName}</strong>,</p>
        <p>The due date for a task assigned to you has been changed.</p>
        <div style="background: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          <table style="width: 100%; border-collapse: collapse;">
            <tr>
              <td style="padding: 4px 0;"><strong>Old Due Date:</strong></td>
              <td style="text-decoration: line-through; color: #EF4444;">${oldDueDate ? new Date(oldDueDate).toLocaleDateString() : 'Not set'}</td>
            </tr>
            <tr>
              <td style="padding: 4px 0;"><strong>New Due Date:</strong></td>
              <td style="color: #10B981;">${newDueDate ? new Date(newDueDate).toLocaleDateString() : 'Not set'}</td>
            </tr>
          </table>
        </div>
        <p>Please log in to the Task Manager for more details.</p>
        <p style="color: #6B7280; font-size: 12px;">This is an automated message from Task Manager.</p>
      </div>
    `,
  };
};

const generateTaskCompletedEmail = (task, assignee, completedBy) => {
  return {
    subject: `Task completed: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #10B981;">Task Completed! 🎉</h2>
        <p>Hi <strong>${assignee.fullName}</strong>,</p>
        <p>${completedBy.fullName} has marked a task as completed.</p>
        <div style="background: #F3F4F6; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          ${task.description ? `<p>${task.description}</p>` : ''}
          <p><strong>Completed at:</strong> ${new Date().toLocaleString()}</p>
        </div>
        <p>Great work! Log in to the Task Manager to see more details.</p>
        <p style="color: #6B7280; font-size: 12px;">This is an automated message from Task Manager.</p>
      </div>
    `,
  };
};

const generateDeadlineReminderEmail = (task, assignee) => {
  return {
    subject: `Reminder: "${task.title}" is due in 24 hours`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #EF4444;">⏰ Deadline Reminder</h2>
        <p>Hi <strong>${assignee.fullName}</strong>,</p>
        <p>This is a reminder that the following task is due within 24 hours.</p>
        <div style="background: #FEF3C7; border-left: 4px solid #F59E0B; padding: 20px; border-radius: 8px; margin: 20px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          ${task.description ? `<p>${task.description}</p>` : ''}
          <p><strong>Due Date:</strong> <span style="color: #EF4444;">${new Date(task.dueDate).toLocaleString()}</span></p>
          <p><strong>Priority:</strong> ${task.priority}</p>
          <p><strong>Status:</strong> ${task.status}</p>
        </div>
        <p>Please log in to the Task Manager and take action.</p>
        <p style="color: #6B7280; font-size: 12px;">This is an automated reminder from Task Manager.</p>
      </div>
    `,
  };
};

const generateTaskCreatedEmail = (task, creator) => {
  return {
    subject: `Công việc mới được tạo: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #4F46E5; margin-top: 0;">Tạo công việc thành công!</h2>
        <p>Xin chào <strong>${creator.fullName}</strong>,</p>
        <p>Bạn vừa tạo thành công công việc mới trên Task Manager với thông tin sau:</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #1F2937;">${task.title}</h3>
          ${task.description ? `<p style="color: #4B5563;">${task.description}</p>` : ''}
          <table style="width: 100%; border-collapse: collapse; margin-top: 8px;">
            <tr>
              <td style="padding: 6px 0; color: #6B7280; width: 40%;"><strong>Mức độ ưu tiên:</strong></td>
              <td style="color: #111827;">${task.priority}</td>
            </tr>
            <tr>
              <td style="padding: 6px 0; color: #6B7280;"><strong>Trạng thái:</strong></td>
              <td style="color: #111827;">${task.status}</td>
            </tr>
            ${task.dueDate ? `<tr><td style="padding: 6px 0; color: #6B7280;"><strong>Hạn hoàn thành:</strong></td><td style="color: #EF4444; font-weight: bold;">${new Date(task.dueDate).toLocaleDateString()}</td></tr>` : ''}
          </table>
        </div>
        <p>Bạn có thể mở ứng dụng Task Manager để quản lý và cập nhật tiến độ công việc.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ Task Manager.</p>
      </div>
    `,
  };
};

module.exports = {
  generateTaskCreatedEmail,
  generateTaskAssignedEmail,
  generateTaskSharedEmail,
  generateDueDateChangedEmail,
  generateTaskCompletedEmail,
  generateDeadlineReminderEmail,
};

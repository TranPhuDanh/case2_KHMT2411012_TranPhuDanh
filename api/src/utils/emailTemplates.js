const generateWelcomeEmail = (user) => {
  return {
    subject: `[Task Manager] Chào mừng ${user.fullName} đến với hệ thống quản lý công việc! 🎉`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #4F46E5; margin-top: 0;">Đăng ký tài khoản thành công! 🎉</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Chúc mừng bạn đã tạo thành công tài khoản trên ứng dụng <strong>Task Manager</strong>.</p>
        <div style="background: #EEF2FF; border-left: 4px solid #4F46E5; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Họ và tên:</strong> ${user.fullName}</p>
          <p style="margin: 0;"><strong>Email đăng nhập:</strong> ${user.email}</p>
        </div>
        <p>Bây giờ bạn có thể bắt đầu tạo, phân công và quản lý các công việc nhóm của mình một cách dễ dàng.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ hệ thống Task Manager.</p>
      </div>
    `,
  };
};

const generateLoginAlertEmail = (user, clientInfo = 'Ứng dụng di động Flutter') => {
  return {
    subject: `[Task Manager] Cảnh báo bảo mật: Phát hiện đăng nhập tài khoản`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #059669; margin-top: 0;">Đăng nhập thành công</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Tài khoản của bạn vừa đăng nhập vào hệ thống Task Manager.</p>
        <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Thời gian:</strong> ${new Date().toLocaleString('vi-VN')}</p>
          <p style="margin: 0 0 8px 0;"><strong>Thiết bị:</strong> ${clientInfo}</p>
          <p style="margin: 0;"><strong>Trạng thái:</strong> Thành công</p>
        </div>
        <p style="color: #4B5563; font-size: 14px;">Nếu đây không phải là bạn, vui lòng đổi mật khẩu ngay lập tức để bảo vệ tài khoản.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email bảo mật tự động từ hệ thống Task Manager.</p>
      </div>
    `,
  };
};

const generateLogoutAlertEmail = (user) => {
  return {
    subject: `[Task Manager] Thông báo: Đăng xuất tài khoản`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #6B7280; margin-top: 0;">Đã đăng xuất tài khoản</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Bạn vừa đăng xuất khỏi ứng dụng Task Manager lúc <strong>${new Date().toLocaleString('vi-VN')}</strong>.</p>
        <p>Phiên làm việc đã kết thúc an toàn. Hẹn gặp lại bạn!</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ hệ thống Task Manager.</p>
      </div>
    `,
  };
};

const generateTaskAssignedEmail = (task, assignee, assigner) => {
  return {
    subject: `[Task Manager] Bạn được giao công việc mới: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #4F46E5; margin-top: 0;">Bạn được giao công việc mới</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p><strong>${assigner.fullName}</strong> đã giao công việc cho bạn phụ trách:</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #1F2937;">${task.title}</h3>
          ${task.description ? `<p style="color: #4B5563;">${task.description}</p>` : ''}
          <table style="width: 100%; border-collapse: collapse; margin-top: 8px;">
            <tr>
              <td style="padding: 4px 0; color: #6B7280; width: 40%;"><strong>Mức độ ưu tiên:</strong></td>
              <td style="color: #111827;">${task.priority}</td>
            </tr>
            <tr>
              <td style="padding: 4px 0; color: #6B7280;"><strong>Trạng thái:</strong></td>
              <td style="color: #111827;">${task.status}</td>
            </tr>
            ${task.dueDate ? `<tr><td style="padding: 4px 0; color: #6B7280;"><strong>Hạn hoàn thành:</strong></td><td style="color: #EF4444; font-weight: bold;">${new Date(task.dueDate).toLocaleDateString()}</td></tr>` : ''}
          </table>
        </div>
        <p>Vui lòng đăng nhập vào ứng dụng Task Manager để xem và cập nhật tiến độ.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ Task Manager.</p>
      </div>
    `,
  };
};

const generateTaskSharedEmail = (task, recipient, sharer, permission) => {
  return {
    subject: `[Task Manager] ${sharer.fullName} đã chia sẻ công việc với bạn: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #0284C7; margin-top: 0;">Công việc được chia sẻ</h2>
        <p>Xin chào <strong>${recipient.fullName}</strong>,</p>
        <p><strong>${sharer.fullName}</strong> đã chia sẻ công việc với bạn với quyền: <strong>${permission === 'editor' ? 'Chỉnh sửa (Editor)' : 'Chỉ xem (Viewer)'}</strong>.</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #1F2937;">${task.title}</h3>
          ${task.description ? `<p style="color: #4B5563;">${task.description}</p>` : ''}
        </div>
        <p>Hãy mở Task Manager để xem chi tiết công việc.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ Task Manager.</p>
      </div>
    `,
  };
};

const generateDueDateChangedEmail = (task, assignee, oldDueDate, newDueDate) => {
  return {
    subject: `[Task Manager] Hạn chót công việc đã cập nhật: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #F59E0B; margin-top: 0;">Thay đổi hạn chót</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p>Hạn hoàn thành công việc của bạn đã được thay đổi:</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          <p>Hạn cũ: <span style="text-decoration: line-through; color: #EF4444;">${oldDueDate ? new Date(oldDueDate).toLocaleDateString() : 'Chưa đặt'}</span></p>
          <p>Hạn mới: <span style="color: #10B981; font-weight: bold;">${newDueDate ? new Date(newDueDate).toLocaleDateString() : 'Chưa đặt'}</span></p>
        </div>
        <p>Vui lòng kiểm tra lại kế hoạch hoàn thành công việc.</p>
      </div>
    `,
  };
};

const generateTaskCompletedEmail = (task, assignee, completedBy) => {
  return {
    subject: `[Task Manager] Công việc đã hoàn thành: ${task.title} 🎉`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #10B981; margin-top: 0;">Công việc hoàn thành! 🎉</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p><strong>${completedBy.fullName}</strong> đã đánh dấu hoàn thành công việc <strong>${task.title}</strong>.</p>
        <p>Tuyệt vời! Hãy tiếp tục duy trì hiệu suất làm việc.</p>
      </div>
    `,
  };
};

const generateDeadlineReminderEmail = (task, assignee) => {
  return {
    subject: `[Task Manager] ⏰ Nhắc nhở: "${task.title}" sắp đến hạn hoàn thành!`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #EF4444; margin-top: 0;">⏰ Nhắc nhở hạn chót</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p>Công việc sau của bạn sắp đến hạn trong vòng 24 giờ tới:</p>
        <div style="background: #FEF3C7; border-left: 4px solid #F59E0B; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #92400E;">${task.title}</h3>
          <p style="margin: 0;"><strong>Hạn chót:</strong> ${new Date(task.dueDate).toLocaleString('vi-VN')}</p>
        </div>
        <p>Vui lòng ưu tiên hoàn thành đúng hạn.</p>
      </div>
    `,
  };
};

const generateTaskCreatedEmail = (task, creator) => {
  return {
    subject: `[Task Manager] Bạn đã tạo công việc mới: ${task.title}`,
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
  generateWelcomeEmail,
  generateLoginAlertEmail,
  generateLogoutAlertEmail,
  generateTaskCreatedEmail,
  generateTaskAssignedEmail,
  generateTaskSharedEmail,
  generateDueDateChangedEmail,
  generateTaskCompletedEmail,
  generateDeadlineReminderEmail,
};

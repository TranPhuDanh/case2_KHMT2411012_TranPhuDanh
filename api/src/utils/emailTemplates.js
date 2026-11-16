const SYSTEM_EMAIL = process.env.SYSTEM_EMAIL || 'tpdanhkhmt2411012@student.ctuet.edu.vn';

const generateWelcomeEmail = (user) => {
  return {
    subject: `[CASE STUDY 2] Xác nhận tạo tài khoản thành công: ${user.email}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #4F46E5; color: white; padding: 18px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h1 style="margin: 0; font-size: 22px; letter-spacing: 1px;">CASE STUDY 2</h1>
          <p style="margin: 4px 0 0 0; font-size: 13px; opacity: 0.95;">Email hệ thống: ${SYSTEM_EMAIL}</p>
        </div>
        <h2 style="color: #4F46E5; margin-top: 0;">Chào mừng bạn đến với CASE STUDY 2! 🎉</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Hệ thống <strong>CASE STUDY 2</strong> (Email điều hành: <em>${SYSTEM_EMAIL}</em>) gửi email thông báo xác nhận bạn vừa tạo tài khoản thành công.</p>
        <div style="background: #EEF2FF; border-left: 4px solid #4F46E5; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Họ và tên:</strong> ${user.fullName}</p>
          <p style="margin: 0 0 8px 0;"><strong>Tài khoản Email:</strong> ${user.email}</p>
          <p style="margin: 0;"><strong>Thời gian đăng ký:</strong> ${new Date().toLocaleString('vi-VN')}</p>
        </div>
        <p>Thông tin tài khoản của bạn đã được lưu trữ an toàn trong cơ sở dữ liệu MongoDB.</p>
        <p>Bây giờ bạn có thể đăng nhập vào ứng dụng để sử dụng đầy đủ các tính năng.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #6B7280; font-size: 12px; margin-bottom: 0;">Email gửi tự động từ hệ thống CASE STUDY 2 &bull; Người phụ trách: ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

const generateLoginAlertEmail = (user, clientInfo = 'Ứng dụng di động Flutter') => {
  return {
    subject: `[CASE STUDY 2] Cảnh báo bảo mật: Phát hiện đăng nhập tài khoản ${user.email}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #059669; color: white; padding: 18px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h1 style="margin: 0; font-size: 22px; letter-spacing: 1px;">CASE STUDY 2</h1>
          <p style="margin: 4px 0 0 0; font-size: 13px; opacity: 0.95;">Email hệ thống: ${SYSTEM_EMAIL}</p>
        </div>
        <h2 style="color: #059669; margin-top: 0;">Thông báo đăng nhập thành công</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Email hệ thống <strong>CASE STUDY 2</strong> (<em>${SYSTEM_EMAIL}</em>) gửi thông báo phát hiện một phiên đăng nhập mới vào tài khoản của bạn:</p>
        <div style="background: #F0FDF4; border-left: 4px solid #10B981; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Tài khoản Email:</strong> ${user.email}</p>
          <p style="margin: 0 0 8px 0;"><strong>Họ và tên:</strong> ${user.fullName}</p>
          <p style="margin: 0 0 8px 0;"><strong>Thời gian:</strong> ${new Date().toLocaleString('vi-VN')}</p>
          <p style="margin: 0 0 8px 0;"><strong>Thiết bị / Nền tảng:</strong> ${clientInfo}</p>
          <p style="margin: 0;"><strong>Trạng thái:</strong> Thành công (Đã ghi vào MongoDB)</p>
        </div>
        <p style="color: #4B5563; font-size: 14px;">Nếu không phải bạn thực hiện đăng nhập, vui lòng đổi mật khẩu ngay lập tức.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #6B7280; font-size: 12px; margin-bottom: 0;">Email bảo mật tự động từ CASE STUDY 2 &bull; Người phụ trách: ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

const generateLogoutAlertEmail = (user) => {
  return {
    subject: `[CASE STUDY 2] Thông báo: Đăng xuất tài khoản ${user.email}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #4B5563; color: white; padding: 18px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h1 style="margin: 0; font-size: 22px; letter-spacing: 1px;">CASE STUDY 2</h1>
          <p style="margin: 4px 0 0 0; font-size: 13px; opacity: 0.95;">Email hệ thống: ${SYSTEM_EMAIL}</p>
        </div>
        <h2 style="color: #4B5563; margin-top: 0;">Đã đăng xuất tài khoản an toàn</h2>
        <p>Xin chào <strong>${user.fullName}</strong>,</p>
        <p>Tài khoản <strong>${user.email}</strong> vừa đăng xuất khỏi hệ thống <strong>CASE STUDY 2</strong> lúc <strong>${new Date().toLocaleString('vi-VN')}</strong>.</p>
        <p>Phiên làm việc đã kết thúc an toàn. Hẹn gặp lại bạn!</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #6B7280; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ CASE STUDY 2 &bull; ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

const generateAdminNotificationEmail = (action, user) => {
  return {
    subject: `[CASE STUDY 2 - ADMIN] Tài khoản ${user.email} vừa ${action}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #1E3A8A; color: white; padding: 16px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h2 style="margin: 0; font-size: 20px;">CASE STUDY 2 - BÁO CÁO HỆ THỐNG</h2>
        </div>
        <h3 style="color: #1E3A8A;">Thông báo hoạt động người dùng:</h3>
        <p>Kính gửi quản trị viên hệ thống CASE STUDY 2 (<strong>${SYSTEM_EMAIL}</strong>),</p>
        <p>Hệ thống vừa ghi nhận một hành động mới:</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <p style="margin: 0 0 8px 0;"><strong>Hành động:</strong> ${action}</p>
          <p style="margin: 0 0 8px 0;"><strong>Họ và tên:</strong> ${user.fullName}</p>
          <p style="margin: 0 0 8px 0;"><strong>Tài khoản Email:</strong> ${user.email}</p>
          <p style="margin: 0;"><strong>Thời gian:</strong> ${new Date().toLocaleString('vi-VN')}</p>
        </div>
        <p>Dữ liệu đã được lưu trữ trong MongoDB.</p>
      </div>
    `,
  };
};

const generateTaskAssignedEmail = (task, assignee, assigner) => {
  return {
    subject: `[CASE STUDY 2] Bạn được giao công việc mới: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #4F46E5; color: white; padding: 14px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h2 style="margin: 0; font-size: 18px;">CASE STUDY 2 - GIAO VIỆC MỚI</h2>
          <p style="margin: 4px 0 0 0; font-size: 12px; opacity: 0.9;">${SYSTEM_EMAIL}</p>
        </div>
        <p>Xin chào <strong>${assignee.fullName}</strong> (${assignee.email}),</p>
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
        <p>Vui lòng đăng nhập vào ứng dụng CASE STUDY 2 để xem và cập nhật tiến độ.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ CASE STUDY 2 &bull; ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

const generateTaskSharedEmail = (task, recipient, sharer, permission) => {
  return {
    subject: `[CASE STUDY 2] ${sharer.fullName} đã chia sẻ công việc với bạn: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #0284C7; color: white; padding: 14px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h2 style="margin: 0; font-size: 18px;">CASE STUDY 2 - CHIA SẺ CÔNG VIỆC</h2>
          <p style="margin: 4px 0 0 0; font-size: 12px; opacity: 0.9;">${SYSTEM_EMAIL}</p>
        </div>
        <p>Xin chào <strong>${recipient.fullName}</strong> (${recipient.email}),</p>
        <p><strong>${sharer.fullName}</strong> đã chia sẻ công việc với bạn với quyền: <strong>${permission === 'editor' ? 'Chỉnh sửa (Editor)' : 'Chỉ xem (Viewer)'}</strong>.</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #1F2937;">${task.title}</h3>
          ${task.description ? `<p style="color: #4B5563;">${task.description}</p>` : ''}
        </div>
        <p>Hãy mở ứng dụng CASE STUDY 2 để xem chi tiết công việc.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ CASE STUDY 2 &bull; ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

const generateDueDateChangedEmail = (task, assignee, oldDueDate, newDueDate) => {
  return {
    subject: `[CASE STUDY 2] Hạn chót công việc đã cập nhật: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #F59E0B; margin-top: 0;">[CASE STUDY 2] Thay đổi hạn chót</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p>Hạn hoàn thành công việc của bạn đã được thay đổi:</p>
        <div style="background: #F3F4F6; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <h3 style="margin-top: 0;">${task.title}</h3>
          <p>Hạn cũ: <span style="text-decoration: line-through; color: #EF4444;">${oldDueDate ? new Date(oldDueDate).toLocaleDateString() : 'Chưa đặt'}</span></p>
          <p>Hạn mới: <span style="color: #10B981; font-weight: bold;">${newDueDate ? new Date(newDueDate).toLocaleDateString() : 'Chưa đặt'}</span></p>
        </div>
      </div>
    `,
  };
};

const generateTaskCompletedEmail = (task, assignee, completedBy) => {
  return {
    subject: `[CASE STUDY 2] Công việc đã hoàn thành: ${task.title} 🎉`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #10B981; margin-top: 0;">[CASE STUDY 2] Công việc hoàn thành! 🎉</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p><strong>${completedBy.fullName}</strong> đã đánh dấu hoàn thành công việc <strong>${task.title}</strong>.</p>
      </div>
    `,
  };
};

const generateDeadlineReminderEmail = (task, assignee) => {
  return {
    subject: `[CASE STUDY 2] ⏰ Nhắc nhở: "${task.title}" sắp đến hạn hoàn thành!`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <h2 style="color: #EF4444; margin-top: 0;">[CASE STUDY 2] ⏰ Nhắc nhở hạn chót</h2>
        <p>Xin chào <strong>${assignee.fullName}</strong>,</p>
        <p>Công việc sau của bạn sắp đến hạn trong vòng 24 giờ tới:</p>
        <div style="background: #FEF3C7; border-left: 4px solid #F59E0B; padding: 16px; border-radius: 6px; margin: 16px 0;">
          <h3 style="margin-top: 0; color: #92400E;">${task.title}</h3>
          <p style="margin: 0;"><strong>Hạn chót:</strong> ${new Date(task.dueDate).toLocaleString('vi-VN')}</p>
        </div>
      </div>
    `,
  };
};

const generateTaskCreatedEmail = (task, creator) => {
  return {
    subject: `[CASE STUDY 2] Bạn đã tạo công việc mới: ${task.title}`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #E5E7EB; border-radius: 8px; padding: 24px;">
        <div style="background: #4F46E5; color: white; padding: 14px; border-radius: 6px; text-align: center; margin-bottom: 20px;">
          <h2 style="margin: 0; font-size: 18px;">CASE STUDY 2 - TẠO CÔNG VIỆC MỚI</h2>
          <p style="margin: 4px 0 0 0; font-size: 12px; opacity: 0.9;">${SYSTEM_EMAIL}</p>
        </div>
        <p>Xin chào <strong>${creator.fullName}</strong> (${creator.email}),</p>
        <p>Bạn vừa tạo thành công công việc mới trên CASE STUDY 2 với thông tin sau:</p>
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
        <p>Bạn có thể mở ứng dụng CASE STUDY 2 để quản lý và cập nhật tiến độ công việc.</p>
        <hr style="border: none; border-top: 1px solid #E5E7EB; margin: 20px 0;" />
        <p style="color: #9CA3AF; font-size: 12px; margin-bottom: 0;">Email thông báo tự động từ CASE STUDY 2 &bull; ${SYSTEM_EMAIL}</p>
      </div>
    `,
  };
};

module.exports = {
  generateWelcomeEmail,
  generateLoginAlertEmail,
  generateLogoutAlertEmail,
  generateAdminNotificationEmail,
  generateTaskCreatedEmail,
  generateTaskAssignedEmail,
  generateTaskSharedEmail,
  generateDueDateChangedEmail,
  generateTaskCompletedEmail,
  generateDeadlineReminderEmail,
};

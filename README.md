# Case Study 2 - Ứng Dụng Quản Lý và Giao Công Việc Nhóm

## Thông tin sinh viên
- **MSSV:** KHMT2411012
- **Họ tên:** Trần Phú Danh

## Mô tả dự án
Ứng dụng quản lý và giao công việc nhóm được xây dựng với:
- **Frontend:** Flutter (TaskManager)
- **Backend:** Node.js + Express REST API (`api/`)
- **Database:** MongoDB
- **Email:** Nodemailer (SMTP)

## Tính năng chính
- ✅ Đăng ký / Đăng nhập / Đăng xuất
- ✅ CRUD công việc (Tạo, Xem, Sửa, Xóa)
- ✅ Giao việc cho nhiều người, chỉ định người phụ trách chính
- ✅ Chia sẻ công việc với quyền viewer/editor
- ✅ Thông báo trong ứng dụng
- ✅ Gửi email khi giao việc / chia sẻ / thay đổi quan trọng
- ✅ Tìm kiếm, lọc, sắp xếp công việc
- ✅ Thống kê công việc theo trạng thái và hạn

## Cài đặt và chạy

### Backend
```bash
cd api
cp .env.example .env
# Chỉnh sửa .env với thông tin MongoDB và SMTP
npm install
npm run dev
```

### Frontend (Flutter)
```bash
flutter pub get
flutter run
```

## Cấu trúc thư mục
```
case_study2/
├── lib/              # Flutter frontend
│   ├── models/       # Data models
│   ├── services/     # API services
│   ├── screens/      # UI screens
│   ├── widgets/      # Reusable widgets
│   └── utils/        # Utilities
├── api/              # Node.js backend
│   └── src/
│       ├── controllers/
│       ├── models/
│       ├── routes/
│       ├── services/
│       └── middleware/
└── README.md
```

## API Base URL
- Local: `http://localhost:3000/api`
- Android Emulator: `http://10.0.2.2:3000/api`

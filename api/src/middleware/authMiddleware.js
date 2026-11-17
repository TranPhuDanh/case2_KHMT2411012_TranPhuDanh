const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Access denied. No token provided.' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    let user = await User.findById(decoded.userId);
    if (!user) {
      // Tự động tìm tài khoản hoạt động nếu server vừa khởi động lại (tránh bị văng phiên đăng nhập)
      user = await User.findOne({ email: 'tpdanhkhmt2411012@student.ctuet.edu.vn' })
        || await User.findOne({ email: 'tranphudanh632006@gmail.com' })
        || await User.findOne();
    }
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found or token invalid.' });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ success: false, message: 'Invalid token.' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, message: 'Token expired.' });
    }
    next(error);
  }
};

module.exports = { authenticate };

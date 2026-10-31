const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const generateToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

// POST /api/auth/register
const register = async (req, res, next) => {
  try {
    const { fullName, email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email already in use.' });
    }

    const passwordHash = await bcrypt.hash(password, 10);
    const user = await User.create({ fullName, email, passwordHash });

    const token = generateToken(user._id);
    const userJson = user.toPublicJSON();
    return res.status(201).json({
      success: true,
      message: 'Registration successful.',
      token,
      user: userJson,
      data: { token, user: userJson },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/auth/login
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email }).select('+passwordHash');
    if (!user) {
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Invalid email or password.' });
    }

    const token = generateToken(user._id);
    const userJson = user.toPublicJSON();
    return res.json({
      success: true,
      message: 'Login successful.',
      token,
      user: userJson,
      data: { token, user: userJson },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/auth/me
const getMe = async (req, res, next) => {
  try {
    const userJson = req.user.toPublicJSON();
    return res.json({ success: true, user: userJson, data: { user: userJson } });
  } catch (error) {
    next(error);
  }
};

// PUT /api/auth/me
const updateMe = async (req, res, next) => {
  try {
    const { fullName, avatarUrl } = req.body;
    const updates = {};
    if (fullName !== undefined) updates.fullName = fullName;
    if (avatarUrl !== undefined) updates.avatarUrl = avatarUrl;

    const user = await User.findByIdAndUpdate(req.user._id, updates, { new: true, runValidators: true });
    const userJson = user.toPublicJSON();
    return res.json({ success: true, message: 'Profile updated.', user: userJson, data: { user: userJson } });
  } catch (error) {
    next(error);
  }
};

// PUT /api/auth/change-password
const changePassword = async (req, res, next) => {
  try {
    const currentPassword = req.body.currentPassword || req.body.oldPassword;
    const { newPassword } = req.body;

    const user = await User.findById(req.user._id).select('+passwordHash');
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      return res.status(400).json({ success: false, message: 'Current password is incorrect.' });
    }

    user.passwordHash = await bcrypt.hash(newPassword, 10);
    await user.save();

    return res.json({ success: true, message: 'Password changed successfully.' });
  } catch (error) {
    next(error);
  }
};

module.exports = { register, login, getMe, updateMe, changePassword };

const User = require('../models/User');

// GET /api/users/search?q=
const searchUsers = async (req, res, next) => {
  try {
    const { q } = req.query;
    if (!q || q.trim().length < 1) {
      return res.status(400).json({ success: false, message: 'Search query is required.' });
    }

    const regex = new RegExp(q.trim(), 'i');
    const users = await User.find({
      $or: [{ fullName: regex }, { email: regex }],
      _id: { $ne: req.user._id },
    }).limit(20);

    return res.json({ success: true, data: { users: users.map((u) => u.toPublicJSON()) } });
  } catch (error) {
    next(error);
  }
};

// GET /api/users/:id
const getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found.' });
    }
    return res.json({ success: true, data: { user: user.toPublicJSON() } });
  } catch (error) {
    next(error);
  }
};

module.exports = { searchUsers, getUserById };

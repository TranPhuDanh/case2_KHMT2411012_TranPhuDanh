const User = require('../models/User');

// GET /api/users/search?q=
const searchUsers = async (req, res, next) => {
  try {
    const { q } = req.query;
    const query = { _id: { $ne: req.user._id } };

    if (q && q.trim().length > 0) {
      const regex = new RegExp(q.trim(), 'i');
      query.$or = [{ fullName: regex }, { email: regex }];
    }

    const users = await User.find(query).limit(20);
    const usersJson = users.map((u) => u.toPublicJSON());

    return res.json({
      success: true,
      users: usersJson,
      data: { users: usersJson },
    });
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

const Task = require('../models/Task');
const TaskShare = require('../models/TaskShare');

// GET /api/statistics/tasks
const getTaskStatistics = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const shares = await TaskShare.find({ userId }).distinct('taskId');

    const matchStage = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }, { _id: { $in: shares } }],
    };

    const stats = await Task.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$status',
          count: { $sum: 1 },
        },
      },
    ]);

    const result = { todo: 0, in_progress: 0, completed: 0, total: 0 };
    for (const s of stats) {
      result[s._id] = s.count;
      result.total += s.count;
    }

    const priorityStats = await Task.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$priority',
          count: { $sum: 1 },
        },
      },
    ]);

    const byPriority = { low: 0, medium: 0, high: 0 };
    for (const s of priorityStats) {
      byPriority[s._id] = s.count;
    }

    return res.json({ success: true, data: { byStatus: result, byPriority } });
  } catch (error) {
    next(error);
  }
};

// GET /api/statistics/assignments
const getAssignmentStatistics = async (req, res, next) => {
  try {
    const userId = req.user._id;

    const [created, assigned, shared] = await Promise.all([
      Task.countDocuments({ createdBy: userId }),
      Task.countDocuments({ assigneeIds: userId }),
      TaskShare.countDocuments({ userId }),
    ]);

    const completedByMe = await Task.countDocuments({
      createdBy: userId,
      status: 'completed',
    });

    return res.json({
      success: true,
      data: {
        tasksCreated: created,
        tasksAssignedToMe: assigned,
        tasksSharedWithMe: shared,
        tasksCompletedByMe: completedByMe,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/statistics/deadlines
const getDeadlineStatistics = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const now = new Date();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const in7d = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    const shares = await TaskShare.find({ userId }).distinct('taskId');

    const baseMatch = {
      $or: [{ createdBy: userId }, { assigneeIds: userId }, { _id: { $in: shares } }],
      status: { $ne: 'completed' },
      dueDate: { $ne: null },
    };

    const [overdue, dueSoon24h, dueSoon7d] = await Promise.all([
      Task.find({ ...baseMatch, dueDate: { $lt: now } })
        .populate('createdBy', 'fullName email')
        .select('title dueDate priority status createdBy')
        .limit(20),
      Task.countDocuments({ ...baseMatch, dueDate: { $gte: now, $lte: in24h } }),
      Task.countDocuments({ ...baseMatch, dueDate: { $gte: now, $lte: in7d } }),
    ]);

    return res.json({
      success: true,
      data: {
        overdue: {
          count: overdue.length,
          tasks: overdue,
        },
        dueSoon: {
          in24Hours: dueSoon24h,
          in7Days: dueSoon7d,
        },
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = { getTaskStatistics, getAssignmentStatistics, getDeadlineStatistics };

const express = require('express');
const router = express.Router();
const { getTaskStatistics, getAssignmentStatistics, getDeadlineStatistics } = require('../controllers/statisticsController');
const { authenticate } = require('../middleware/authMiddleware');

router.get('/tasks', authenticate, getTaskStatistics);
router.get('/assignments', authenticate, getAssignmentStatistics);
router.get('/deadlines', authenticate, getDeadlineStatistics);

module.exports = router;

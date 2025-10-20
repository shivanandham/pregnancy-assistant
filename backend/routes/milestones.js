const express = require('express');
const router = express.Router();
const MilestonesController = require('../controllers/milestonesController');
const { auth } = require('../middleware/auth');

// GET /api/milestones/current - Get milestones for current pregnancy week
router.get('/current', auth, MilestonesController.getCurrentWeekMilestones);

// GET /api/milestones/week/:week - Get milestones for a specific week
router.get('/week/:week', auth, MilestonesController.getMilestonesForWeek);

// GET /api/milestones/range - Get milestones for a range of weeks
router.get('/range', auth, MilestonesController.getMilestonesForWeekRange);

// GET /api/milestones/upcoming - Get upcoming milestones
router.get('/upcoming', auth, MilestonesController.getUpcomingMilestones);

// GET /api/milestones/recent - Get recent milestones
router.get('/recent', auth, MilestonesController.getRecentMilestones);

// GET /api/milestones/trimester/:trimester - Get milestones by trimester
router.get('/trimester/:trimester', auth, MilestonesController.getMilestonesByTrimester);

// GET /api/milestones/all - Get all available milestones
router.get('/all', auth, MilestonesController.getAllMilestones);

module.exports = router;

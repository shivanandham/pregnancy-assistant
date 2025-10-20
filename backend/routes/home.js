const express = require('express');
const router = express.Router();
const HomeController = require('../controllers/homeController');
const CronService = require('../services/cronService');
const { auth } = require('../middleware/auth');

// GET /api/home - Get all home screen data
router.get('/', auth, HomeController.getHomeData);

// GET /api/home/tips/:week - Get tips for a specific week
router.get('/tips/:week', auth, HomeController.getTipsForWeek);

// GET /api/home/milestones/:week - Get milestones for a specific week
router.get('/milestones/:week', auth, HomeController.getMilestonesForWeek);

// GET /api/home/checklist/generate - Generate dynamic checklist for a specific date
router.get('/checklist/generate', auth, HomeController.generateDynamicChecklist);

// GET /api/home/checklist/completions/:date - Get checklist completions for a specific date
router.get('/checklist/completions/:date', auth, HomeController.getChecklistCompletions);

// GET /api/home/checklist/:week - Get daily checklist for a specific week
router.get('/checklist/:week', auth, HomeController.getChecklistForWeek);

// POST /api/home/clear-tips - Clear expired tips (maintenance)
router.post('/clear-tips', auth, HomeController.clearExpiredTips);

// POST /api/home/checklist/:checklistItemId/toggle - Toggle checklist item completion
router.post('/checklist/:checklistItemId/toggle', auth, HomeController.toggleChecklistCompletion);

// POST /api/home/cron/trigger-daily-checklist - Manually trigger daily checklist generation (for testing)
router.post('/cron/trigger-daily-checklist', async (req, res) => {
  try {
    await CronService.triggerDailyChecklistGeneration();
    res.json({
      success: true,
      message: 'Daily checklist generation triggered successfully'
    });
  } catch (error) {
    console.error('Error triggering daily checklist generation:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
});

module.exports = router;

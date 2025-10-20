const express = require('express');
const router = express.Router();
const HomeController = require('../controllers/homeController');
const CronService = require('../services/cronService');
const { auth } = require('../middleware/auth');

// GET /api/home - Get all home screen data
router.get('/', auth, HomeController.getHomeData);

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

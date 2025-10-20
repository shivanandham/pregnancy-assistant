const express = require('express');
const router = express.Router();
const TipsController = require('../controllers/tipsController');
const { auth } = require('../middleware/auth');

// GET /api/tips/current - Get tips for current pregnancy week
router.get('/current', auth, TipsController.getCurrentWeekTips);

// GET /api/tips/week/:week - Get tips for a specific week
router.get('/week/:week', auth, TipsController.getTipsForWeek);

// GET /api/tips/range - Get tips for a range of weeks
router.get('/range', auth, TipsController.getTipsForWeekRange);

// GET /api/tips/category/:category - Get tips by category
router.get('/category/:category', auth, TipsController.getTipsByCategory);

// POST /api/tips - Create a new tip (admin/maintenance)
router.post('/', auth, TipsController.createTip);

// PUT /api/tips/:id - Update a tip (admin/maintenance)
router.put('/:id', auth, TipsController.updateTip);

// DELETE /api/tips/:id - Delete a tip (admin/maintenance)
router.delete('/:id', auth, TipsController.deleteTip);

// POST /api/tips/clear-expired - Clear expired tips (maintenance)
router.post('/clear-expired', auth, TipsController.clearExpiredTips);

module.exports = router;

const express = require('express');
const router = express.Router();
const ChecklistController = require('../controllers/checklistController');
const { auth } = require('../middleware/auth');

// GET /api/checklist/current - Get current week dynamic checklist
router.get('/current', auth, ChecklistController.getCurrentWeekChecklist);

// GET /api/checklist/week/:week - Get daily checklist for a specific week
router.get('/week/:week', auth, ChecklistController.getChecklistForWeek);

// GET /api/checklist/generate - Generate dynamic checklist for a specific date
router.get('/generate', auth, ChecklistController.generateDynamicChecklist);

// GET /api/checklist/category/:category - Get checklist items by category
router.get('/category/:category', auth, ChecklistController.getChecklistByCategory);

// GET /api/checklist/completions/:date - Get checklist completions for a specific date
router.get('/completions/:date', auth, ChecklistController.getChecklistCompletions);

// GET /api/checklist/completions/range - Get checklist completions for a date range
router.get('/completions/range', auth, ChecklistController.getChecklistCompletionsForRange);

// GET /api/checklist/stats - Get checklist statistics
router.get('/stats', auth, ChecklistController.getChecklistStats);

// POST /api/checklist/:checklistItemId/toggle - Toggle checklist item completion
router.post('/:checklistItemId/toggle', auth, ChecklistController.toggleChecklistCompletion);

module.exports = router;

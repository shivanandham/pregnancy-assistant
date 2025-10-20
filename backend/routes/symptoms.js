const express = require('express');
const router = express.Router();
const SymptomController = require('../controllers/symptomController');
const { auth } = require('../middleware/auth');

// GET /api/symptoms - Get all symptoms
router.get('/', auth, SymptomController.getAll);

// GET /api/symptoms/range - Get symptoms by date range
router.get('/range', auth, SymptomController.getByDateRange);

// GET /api/symptoms/:id - Get symptom by ID
router.get('/:id', auth, SymptomController.getById);

// POST /api/symptoms - Create new symptom
router.post('/', auth, SymptomController.create);

// DELETE /api/symptoms/:id - Delete symptom
router.delete('/:id', auth, SymptomController.delete);

module.exports = router;

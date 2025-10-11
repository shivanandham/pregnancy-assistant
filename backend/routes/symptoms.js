const express = require('express');
const router = express.Router();
const SymptomController = require('../controllers/symptomController');

// GET /api/symptoms - Get all symptoms
router.get('/', SymptomController.getAll);

// GET /api/symptoms/range - Get symptoms by date range
router.get('/range', SymptomController.getByDateRange);

// GET /api/symptoms/:id - Get symptom by ID
router.get('/:id', SymptomController.getById);

// POST /api/symptoms - Create new symptom
router.post('/', SymptomController.create);

// DELETE /api/symptoms/:id - Delete symptom
router.delete('/:id', SymptomController.delete);

module.exports = router;

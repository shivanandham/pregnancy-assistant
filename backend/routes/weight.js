const express = require('express');
const router = express.Router();
const WeightController = require('../controllers/weightController');

// GET /api/weight - Get all weight entries
router.get('/', WeightController.getAll);

// GET /api/weight/range - Get weight entries by date range
router.get('/range', WeightController.getByDateRange);

// GET /api/weight/:id - Get weight entry by ID
router.get('/:id', WeightController.getById);

// POST /api/weight - Create new weight entry
router.post('/', WeightController.create);

// DELETE /api/weight/:id - Delete weight entry
router.delete('/:id', WeightController.delete);

module.exports = router;

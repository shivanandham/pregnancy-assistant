const express = require('express');
const router = express.Router();
const WeightController = require('../controllers/weightController');
const { auth } = require('../middleware/auth');

// GET /api/weight - Get all weight entries
router.get('/', auth, WeightController.getAll);

// GET /api/weight/range - Get weight entries by date range
router.get('/range', auth, WeightController.getByDateRange);

// GET /api/weight/:id - Get weight entry by ID
router.get('/:id', auth, WeightController.getById);

// POST /api/weight - Create new weight entry
router.post('/', auth, WeightController.create);

// DELETE /api/weight/:id - Delete weight entry
router.delete('/:id', auth, WeightController.delete);

module.exports = router;

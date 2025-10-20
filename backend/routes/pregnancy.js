const express = require('express');
const router = express.Router();
const PregnancyController = require('../controllers/pregnancyController');
const { auth } = require('../middleware/auth');

// GET /api/pregnancy - Get current pregnancy data
router.get('/', auth, PregnancyController.getCurrent);

// POST /api/pregnancy - Create or update pregnancy data
router.post('/', auth, PregnancyController.createOrUpdate);

// DELETE /api/pregnancy - Delete pregnancy data
router.delete('/', auth, PregnancyController.delete);

module.exports = router;

const express = require('express');
const router = express.Router();
const PregnancyController = require('../controllers/pregnancyController');

// GET /api/pregnancy - Get current pregnancy data
router.get('/', PregnancyController.getCurrent);

// POST /api/pregnancy - Create or update pregnancy data
router.post('/', PregnancyController.createOrUpdate);

// DELETE /api/pregnancy - Delete pregnancy data
router.delete('/', PregnancyController.delete);

module.exports = router;

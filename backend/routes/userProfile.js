const express = require('express');
const router = express.Router();
const UserProfileController = require('../controllers/userProfileController');

// GET /api/user-profile - Get user profile
router.get('/', UserProfileController.getProfile);

// POST /api/user-profile - Create or update user profile
router.post('/', UserProfileController.saveProfile);

// PATCH /api/user-profile - Update specific profile fields
router.patch('/', UserProfileController.updateProfile);

// GET /api/user-profile/context - Get profile context for AI
router.get('/context', UserProfileController.getProfileContext);

module.exports = router;

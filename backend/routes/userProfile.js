const express = require('express');
const router = express.Router();
const UserProfileController = require('../controllers/userProfileController');
const { auth } = require('../middleware/auth');

// GET /api/user-profile - Get user profile
router.get('/', auth, UserProfileController.getProfile);

// POST /api/user-profile - Create or update user profile
router.post('/', auth, UserProfileController.saveProfile);

// PATCH /api/user-profile - Update specific profile fields
router.patch('/', auth, UserProfileController.updateProfile);

// GET /api/user-profile/context - Get profile context for AI
router.get('/context', auth, UserProfileController.getProfileContext);

module.exports = router;

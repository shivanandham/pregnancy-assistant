const express = require('express');
const AuthController = require('../controllers/authController');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Sync user data (called after Google sign-in)
router.post('/sync', AuthController.syncUser);

// Get user profile (requires authentication)
router.get('/profile', auth, AuthController.getProfile);

// Delete user account (requires authentication)
router.delete('/account', auth, AuthController.deleteAccount);

module.exports = router;

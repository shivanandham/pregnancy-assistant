const express = require('express');
const AuthController = require('../controllers/authController');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Login with Firebase token, get session token
router.post('/login', AuthController.login);

// Refresh session token
router.post('/refresh', AuthController.refreshToken);

// Logout current session (requires authentication)
router.post('/logout', auth, AuthController.logout);

// Logout all sessions (requires authentication)
router.post('/logout-all', auth, AuthController.logoutAll);

// Sync user data (legacy endpoint for backward compatibility)
router.post('/sync', AuthController.syncUser);

// Get user profile (requires authentication)
router.get('/profile', auth, AuthController.getProfile);

// Delete user account (requires authentication)
router.delete('/account', auth, AuthController.deleteAccount);

module.exports = router;

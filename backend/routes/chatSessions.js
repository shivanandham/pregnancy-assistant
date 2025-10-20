const express = require('express');
const router = express.Router();
const ChatSessionController = require('../controllers/chatSessionController');
const { auth } = require('../middleware/auth');

// Get all chat sessions
router.get('/', auth, ChatSessionController.getAllSessions);

// Get active session
router.get('/active', auth, ChatSessionController.getActiveSession);

// Create new session
router.post('/', auth, ChatSessionController.createSession);

// Get session by ID with messages
router.get('/:id', auth, ChatSessionController.getSessionById);

// Set active session
router.put('/:id/activate', auth, ChatSessionController.setActiveSession);

// Update session title
router.put('/:id/title', auth, ChatSessionController.updateSessionTitle);

// Delete session
router.delete('/:id', auth, ChatSessionController.deleteSession);

module.exports = router;


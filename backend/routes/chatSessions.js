const express = require('express');
const router = express.Router();
const ChatSessionController = require('../controllers/chatSessionController');

// Get all chat sessions
router.get('/', ChatSessionController.getAllSessions);

// Get active session
router.get('/active', ChatSessionController.getActiveSession);

// Create new session
router.post('/', ChatSessionController.createSession);

// Get session by ID with messages
router.get('/:id', ChatSessionController.getSessionById);

// Set active session
router.put('/:id/activate', ChatSessionController.setActiveSession);

// Update session title
router.put('/:id/title', ChatSessionController.updateSessionTitle);

// Delete session
router.delete('/:id', ChatSessionController.deleteSession);

module.exports = router;


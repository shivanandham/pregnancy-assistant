const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/chatController');
const { auth } = require('../middleware/auth');

// POST /api/chat - Send chat message
router.post('/', auth, ChatController.sendMessage);

// POST /api/chat/diagnostic - Answer diagnostic questions
router.post('/diagnostic', auth, ChatController.answerDiagnosticQuestions);

// GET /api/chat/history - Get chat history
router.get('/history', auth, ChatController.getHistory);

// DELETE /api/chat/history - Clear chat history
router.delete('/history', auth, ChatController.clearHistory);

// GET /api/chat/:id - Get message by ID
router.get('/:id', auth, ChatController.getMessageById);

// DELETE /api/chat/:id - Delete message
router.delete('/:id', auth, ChatController.deleteMessage);

module.exports = router;

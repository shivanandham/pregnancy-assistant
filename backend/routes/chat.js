const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/chatController');

// POST /api/chat - Send chat message
router.post('/', ChatController.sendMessage);

// POST /api/chat/diagnostic - Answer diagnostic questions
router.post('/diagnostic', ChatController.answerDiagnosticQuestions);

// GET /api/chat/history - Get chat history
router.get('/history', ChatController.getHistory);

// DELETE /api/chat/history - Clear chat history
router.delete('/history', ChatController.clearHistory);

// GET /api/chat/:id - Get message by ID
router.get('/:id', ChatController.getMessageById);

// DELETE /api/chat/:id - Delete message
router.delete('/:id', ChatController.deleteMessage);

module.exports = router;

const express = require('express');
const KnowledgeController = require('../controllers/knowledgeController');
const { validateQuery, validateParams } = require('../middleware/validation');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Get all facts with optional filtering
router.get('/facts', auth, KnowledgeController.getFacts);

// Get facts by category
router.get('/facts/category/:category', auth, KnowledgeController.getFactsByCategory);

// Search facts and conversations
router.get('/search', auth, KnowledgeController.search);

// Get knowledge timeline
router.get('/timeline', auth, KnowledgeController.getTimeline);

// Get knowledge statistics
router.get('/stats', auth, KnowledgeController.getStats);

// Get conversations by week
router.get('/conversations/week/:week', auth, KnowledgeController.getConversationsByWeek);

// Delete a specific fact
router.delete('/facts/:id', auth, KnowledgeController.deleteFact);

// Delete a conversation chunk
router.delete('/conversations/:id', auth, KnowledgeController.deleteConversation);

// Clear all knowledge data (use with caution)
router.delete('/clear', auth, KnowledgeController.clearAll);

module.exports = router;

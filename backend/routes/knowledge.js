const express = require('express');
const KnowledgeController = require('../controllers/knowledgeController');
const { validateQuery, validateParams } = require('../middleware/validation');

const router = express.Router();

// Get all facts with optional filtering
router.get('/facts', KnowledgeController.getFacts);

// Get facts by category
router.get('/facts/category/:category', KnowledgeController.getFactsByCategory);

// Search facts and conversations
router.get('/search', KnowledgeController.search);

// Get knowledge timeline
router.get('/timeline', KnowledgeController.getTimeline);

// Get knowledge statistics
router.get('/stats', KnowledgeController.getStats);

// Get conversations by week
router.get('/conversations/week/:week', KnowledgeController.getConversationsByWeek);

// Delete a specific fact
router.delete('/facts/:id', KnowledgeController.deleteFact);

// Delete a conversation chunk
router.delete('/conversations/:id', KnowledgeController.deleteConversation);

// Clear all knowledge data (use with caution)
router.delete('/clear', KnowledgeController.clearAll);

module.exports = router;

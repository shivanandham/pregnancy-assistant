const KnowledgeFact = require('../models/KnowledgeFact');
const ConversationChunk = require('../models/ConversationChunk');
const KnowledgeRetriever = require('../services/knowledgeRetriever');
const KnowledgeExtractor = require('../services/knowledgeExtractor');

class KnowledgeController {
  // Get all facts with optional filtering
  static async getFacts(req, res) {
    try {
      const { category, week, limit = 50 } = req.query;
      
      let facts;
      if (category) {
        facts = await KnowledgeFact.getByCategory(category, parseInt(limit));
      } else if (week) {
        const weekNum = parseInt(week);
        facts = await KnowledgeFact.getByWeekRange(weekNum, weekNum, parseInt(limit));
      } else {
        facts = await KnowledgeFact.getRecent(parseInt(limit));
      }
      
      res.json({
        success: true,
        data: facts.map(fact => fact.toJSON())
      });
    } catch (error) {
      console.error('Error getting facts:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get facts'
      });
    }
  }

  // Search facts and conversations
  static async search(req, res) {
    try {
      const { query, type = 'all', limit = 20 } = req.query;
      
      if (!query) {
        return res.status(400).json({
          success: false,
          message: 'Search query is required'
        });
      }

      const results = {
        facts: [],
        conversations: []
      };

      if (type === 'all' || type === 'facts') {
        results.facts = await KnowledgeFact.search(query, parseInt(limit));
      }

      if (type === 'all' || type === 'conversations') {
        results.conversations = await ConversationChunk.search(query, parseInt(limit));
      }

      res.json({
        success: true,
        data: {
          facts: results.facts.map(fact => fact.toJSON()),
          conversations: results.conversations.map(conv => conv.toJSON()),
          query,
          totalResults: results.facts.length + results.conversations.length
        }
      });
    } catch (error) {
      console.error('Error searching knowledge:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to search knowledge'
      });
    }
  }

  // Get knowledge timeline
  static async getTimeline(req, res) {
    try {
      const { startWeek, endWeek } = req.query;
      
      const weeks = startWeek && endWeek ? {
        start: parseInt(startWeek),
        end: parseInt(endWeek)
      } : null;
      
      const timeline = await KnowledgeRetriever.getKnowledgeTimeline(weeks);
      
      res.json({
        success: true,
        data: {
          timeline: timeline.map(item => ({
            type: item.type,
            data: item.data.toJSON(),
            date: item.date,
            week: item.week
          })),
          totalItems: timeline.length
        }
      });
    } catch (error) {
      console.error('Error getting timeline:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get timeline'
      });
    }
  }

  // Get knowledge statistics
  static async getStats(req, res) {
    try {
      const stats = await KnowledgeExtractor.getExtractionStats();
      
      res.json({
        success: true,
        data: stats
      });
    } catch (error) {
      console.error('Error getting stats:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get statistics'
      });
    }
  }

  // Delete a specific fact
  static async deleteFact(req, res) {
    try {
      const { id } = req.params;
      
      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'Fact ID is required'
        });
      }

      const fact = await KnowledgeFact.getById(id);
      if (!fact) {
        return res.status(404).json({
          success: false,
          message: 'Fact not found'
        });
      }

      await KnowledgeFact.delete(id);
      
      res.json({
        success: true,
        message: 'Fact deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting fact:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete fact'
      });
    }
  }

  // Delete a conversation chunk
  static async deleteConversation(req, res) {
    try {
      const { id } = req.params;
      
      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'Conversation ID is required'
        });
      }

      const conversation = await ConversationChunk.getById(id);
      if (!conversation) {
        return res.status(404).json({
          success: false,
          message: 'Conversation not found'
        });
      }

      await ConversationChunk.delete(id);
      
      res.json({
        success: true,
        message: 'Conversation deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting conversation:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete conversation'
      });
    }
  }

  // Clear all knowledge data
  static async clearAll(req, res) {
    try {
      await KnowledgeFact.clearAll();
      await ConversationChunk.clearAll();
      
      res.json({
        success: true,
        message: 'All knowledge data cleared successfully'
      });
    } catch (error) {
      console.error('Error clearing knowledge:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to clear knowledge data'
      });
    }
  }

  // Get facts by category
  static async getFactsByCategory(req, res) {
    try {
      const { category } = req.params;
      const { limit = 50 } = req.query;
      
      const validCategories = ['symptom', 'milestone', 'preference', 'medical', 'activity'];
      if (!validCategories.includes(category)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid category. Must be one of: ' + validCategories.join(', ')
        });
      }

      const facts = await KnowledgeFact.getByCategory(category, parseInt(limit));
      
      res.json({
        success: true,
        data: {
          category,
          facts: facts.map(fact => fact.toJSON()),
          count: facts.length
        }
      });
    } catch (error) {
      console.error('Error getting facts by category:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get facts by category'
      });
    }
  }

  // Get conversations by week
  static async getConversationsByWeek(req, res) {
    try {
      const { week } = req.params;
      const { limit = 20 } = req.query;
      
      const weekNum = parseInt(week);
      if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week number. Must be between 1 and 42'
        });
      }

      const conversations = await ConversationChunk.getByWeek(weekNum, parseInt(limit));
      
      res.json({
        success: true,
        data: {
          week: weekNum,
          conversations: conversations.map(conv => conv.toJSON()),
          count: conversations.length
        }
      });
    } catch (error) {
      console.error('Error getting conversations by week:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get conversations by week'
      });
    }
  }
}

module.exports = KnowledgeController;

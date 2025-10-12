const ChatSession = require('../models/ChatSession');
const ChatMessage = require('../models/ChatMessage');

class ChatSessionController {
  // Get all chat sessions
  static async getAllSessions(req, res) {
    try {
      const sessions = await ChatSession.getAll();
      res.json({
        success: true,
        data: sessions
      });
    } catch (error) {
      console.error('Error getting chat sessions:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get chat sessions'
      });
    }
  }

  // Get active session
  static async getActiveSession(req, res) {
    try {
      const session = await ChatSession.getActive();
      res.json({
        success: true,
        data: session
      });
    } catch (error) {
      console.error('Error getting active session:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get active session'
      });
    }
  }

  // Create new chat session
  static async createSession(req, res) {
    try {
      const { title } = req.body;
      const session = await ChatSession.createNew(title);
      
      res.json({
        success: true,
        data: session
      });
    } catch (error) {
      console.error('Error creating chat session:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create chat session'
      });
    }
  }

  // Get session by ID with messages
  static async getSessionById(req, res) {
    try {
      const { id } = req.params;
      const session = await ChatSession.getById(id);
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }

      // Get messages for this session
      const messages = await ChatMessage.getBySessionId(id);
      
      res.json({
        success: true,
        data: {
          session,
          messages
        }
      });
    } catch (error) {
      console.error('Error getting session:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get session'
      });
    }
  }

  // Set active session
  static async setActiveSession(req, res) {
    try {
      const { id } = req.params;
      await ChatSession.setActive(id);
      
      res.json({
        success: true,
        message: 'Session activated'
      });
    } catch (error) {
      console.error('Error setting active session:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to set active session'
      });
    }
  }

  // Update session title
  static async updateSessionTitle(req, res) {
    try {
      const { id } = req.params;
      const { title } = req.body;
      
      await ChatSession.updateTitle(id, title);
      
      res.json({
        success: true,
        message: 'Session title updated'
      });
    } catch (error) {
      console.error('Error updating session title:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update session title'
      });
    }
  }

  // Delete session
  static async deleteSession(req, res) {
    try {
      const { id } = req.params;
      await ChatSession.delete(id);
      
      res.json({
        success: true,
        message: 'Session deleted'
      });
    } catch (error) {
      console.error('Error deleting session:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete session'
      });
    }
  }
}

module.exports = ChatSessionController;


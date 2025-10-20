const prisma = require('../lib/prisma');

class ChatSessionController {
  // Get all chat sessions
  static async getAllSessions(req, res) {
    try {
      const userId = req.dbUser.id;
      const sessions = await prisma.chatSession.findMany({
        where: { userId },
        orderBy: { updatedAt: 'desc' },
        include: {
          messages: {
            orderBy: { timestamp: 'asc' }
          }
        }
      });
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
      const userId = req.dbUser.id;
      const session = await prisma.chatSession.findFirst({
        where: { 
          userId,
          isActive: true 
        },
        include: {
          messages: {
            orderBy: { timestamp: 'asc' }
          }
        }
      });
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
      const userId = req.dbUser.id;
      const { title } = req.body;
      
      // Deactivate all other sessions for this user
      await prisma.chatSession.updateMany({
        where: { userId },
        data: { isActive: false }
      });
      
      // Create new session
      const session = await prisma.chatSession.create({
        data: {
          userId,
          title: title || 'New Chat',
          isActive: true
        }
      });
      
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      const session = await prisma.chatSession.findFirst({
        where: { 
          id,
          userId 
        },
        include: {
          messages: {
            orderBy: { timestamp: 'asc' }
          }
        }
      });
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }
      
      res.json({
        success: true,
        data: session
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      
      // Verify session belongs to user
      const session = await prisma.chatSession.findFirst({
        where: { 
          id,
          userId 
        }
      });
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }
      
      // Deactivate all other sessions
      await prisma.chatSession.updateMany({
        where: { userId },
        data: { isActive: false }
      });
      
      // Activate this session
      await prisma.chatSession.update({
        where: { id },
        data: { isActive: true }
      });
      
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      const { title } = req.body;
      
      // Verify session belongs to user
      const session = await prisma.chatSession.findFirst({
        where: { 
          id,
          userId 
        }
      });
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }
      
      await prisma.chatSession.update({
        where: { id },
        data: { title }
      });
      
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      
      // Verify session belongs to user
      const session = await prisma.chatSession.findFirst({
        where: { 
          id,
          userId 
        }
      });
      
      if (!session) {
        return res.status(404).json({
          success: false,
          message: 'Session not found'
        });
      }
      
      await prisma.chatSession.delete({
        where: { id }
      });
      
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


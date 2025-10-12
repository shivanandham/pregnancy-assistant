const { v4: uuidv4 } = require('uuid');
const prisma = require('../lib/prisma');

class ChatSession {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.title = data.title || 'New Chat';
    this.createdAt = data.createdAt || new Date();
    this.updatedAt = data.updatedAt || new Date();
    this.messageCount = data.messageCount || 0;
    this.isActive = data.isActive || false;
  }

  async save() {
    await prisma.chatSession.create({
      data: {
        id: this.id,
        title: this.title,
        createdAt: new Date(this.createdAt),
        updatedAt: new Date(this.updatedAt),
        messageCount: this.messageCount,
        isActive: this.isActive
      }
    });
  }

  async update() {
    await prisma.chatSession.update({
      where: { id: this.id },
      data: {
        title: this.title,
        updatedAt: new Date(this.updatedAt),
        messageCount: this.messageCount,
        isActive: this.isActive
      }
    });
  }

  static async getAll() {
    // Get sessions ordered by the most recent message timestamp
    const sessions = await prisma.chatSession.findMany({
      include: {
        messages: {
          orderBy: { timestamp: 'desc' },
          take: 1 // Only get the latest message for ordering
        }
      },
      orderBy: [
        // First order by whether there are messages (sessions with messages first)
        { messageCount: 'desc' },
        // Then by the timestamp of the latest message
        { messages: { _count: 'desc' } }
      ]
    });
    
    // Sort by the actual latest message timestamp
    const sortedSessions = sessions.sort((a, b) => {
      const aLatestMessage = a.messages[0];
      const bLatestMessage = b.messages[0];
      
      // If both have messages, sort by message timestamp
      if (aLatestMessage && bLatestMessage) {
        return new Date(bLatestMessage.timestamp) - new Date(aLatestMessage.timestamp);
      }
      
      // If only one has messages, prioritize it
      if (aLatestMessage && !bLatestMessage) return -1;
      if (!aLatestMessage && bLatestMessage) return 1;
      
      // If neither has messages, sort by session updatedAt
      return new Date(b.updatedAt) - new Date(a.updatedAt);
    });
    
    return sortedSessions.map(session => new ChatSession({
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messageCount: session.messageCount,
      isActive: session.isActive
    }));
  }

  static async getById(id) {
    const session = await prisma.chatSession.findUnique({
      where: { id }
    });
    
    if (!session) return null;
    
    return new ChatSession({
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messageCount: session.messageCount,
      isActive: session.isActive
    });
  }

  static async getActive() {
    const session = await prisma.chatSession.findFirst({
      where: { isActive: true },
      orderBy: { updatedAt: 'desc' }
    });
    
    if (!session) return null;
    
    return new ChatSession({
      id: session.id,
      title: session.title,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      messageCount: session.messageCount,
      isActive: session.isActive
    });
  }

  static async createNew(title = 'New Chat') {
    // Deactivate all existing sessions
    await prisma.chatSession.updateMany({
      data: { isActive: false }
    });

    // Create new session
    const session = new ChatSession({
      title,
      isActive: true
    });
    
    await session.save();
    return session;
  }

  static async incrementMessageCount(id) {
    await prisma.chatSession.update({
      where: { id },
      data: { 
        messageCount: { increment: 1 },
        updatedAt: new Date()
      }
    });
  }

  static async delete(id) {
    // First delete all messages in this session
    await prisma.chatMessage.deleteMany({
      where: { sessionId: id }
    });
    
    // Then delete the session
    await prisma.chatSession.delete({
      where: { id }
    });
  }

  static async setActive(id) {
    // Deactivate all sessions
    await prisma.chatSession.updateMany({
      data: { isActive: false }
    });

    // Activate the selected session
    await prisma.chatSession.update({
      where: { id },
      data: { 
        isActive: true,
        updatedAt: new Date()
      }
    });
  }

  static async updateTitle(id, title) {
    await prisma.chatSession.update({
      where: { id },
      data: { 
        title,
        updatedAt: new Date()
      }
    });
  }

  static async incrementMessageCount(id) {
    await prisma.chatSession.update({
      where: { id },
      data: { 
        messageCount: { increment: 1 },
        updatedAt: new Date()
      }
    });
  }
}

module.exports = ChatSession;


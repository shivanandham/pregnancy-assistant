const { v4: uuidv4 } = require('uuid');
const prisma = require('../lib/prisma');

class ConversationChunk {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.content = data.content;
    this.weekNumber = data.weekNumber || null;
    this.timestamp = data.timestamp || new Date().toISOString();
    this.keywords = data.keywords || '';
    this.createdAt = data.createdAt || new Date().toISOString();
  }

  async save() {
    await prisma.conversationChunk.create({
      data: {
        id: this.id,
        content: this.content,
        weekNumber: this.weekNumber,
        timestamp: new Date(this.timestamp),
        keywords: this.keywords,
        createdAt: new Date(this.createdAt)
      }
    });
    
    return this;
  }

  static async getAll() {
    const chunks = await prisma.conversationChunk.findMany({
      orderBy: {
        timestamp: 'desc'
      }
    });
    
    return chunks.map(chunk => new ConversationChunk({
      id: chunk.id,
      content: chunk.content,
      weekNumber: chunk.weekNumber,
      timestamp: chunk.timestamp,
      keywords: chunk.keywords,
      createdAt: chunk.createdAt
    }));
  }

  static async getById(id) {
    const chunk = await prisma.conversationChunk.findUnique({
      where: { id }
    });
    
    if (chunk) {
      return new ConversationChunk({
        id: chunk.id,
        content: chunk.content,
        weekNumber: chunk.weekNumber,
        timestamp: chunk.timestamp,
        keywords: chunk.keywords,
        createdAt: chunk.createdAt
      });
    }
    
    return null;
  }

  static async search(query, limit = 20) {
    // Use Prisma for search
    const chunks = await prisma.conversationChunk.findMany({
      where: {
        OR: [
          { content: { contains: query, mode: 'insensitive' } },
          { keywords: { contains: query, mode: 'insensitive' } }
        ]
      },
      orderBy: { timestamp: 'desc' },
      take: limit
    });
    
    return chunks.map(chunk => new ConversationChunk({
      id: chunk.id,
      content: chunk.content,
      weekNumber: chunk.weekNumber,
      timestamp: chunk.timestamp,
      keywords: chunk.keywords,
      createdAt: chunk.createdAt
    }));
  }

  static async getRecent(limit = 50) {
    const chunks = await prisma.conversationChunk.findMany({
      orderBy: { timestamp: 'desc' },
      take: limit
    });
    
    return chunks.map(chunk => new ConversationChunk({
      id: chunk.id,
      content: chunk.content,
      weekNumber: chunk.weekNumber,
      timestamp: chunk.timestamp,
      keywords: chunk.keywords,
      createdAt: chunk.createdAt
    }));
  }

  static async getByWeek(week, limit = 20) {
    const chunks = await prisma.conversationChunk.findMany({
      where: { weekNumber: week },
      orderBy: { timestamp: 'desc' },
      take: limit
    });
    
    return chunks.map(chunk => new ConversationChunk({
      id: chunk.id,
      content: chunk.content,
      weekNumber: chunk.weekNumber,
      timestamp: chunk.timestamp,
      keywords: chunk.keywords,
      createdAt: chunk.createdAt
    }));
  }

  static async getByWeekRange(startWeek, endWeek, limit = 50) {
    const chunks = await prisma.conversationChunk.findMany({
      where: {
        weekNumber: {
          gte: startWeek,
          lte: endWeek
        }
      },
      orderBy: [
        { weekNumber: 'asc' },
        { timestamp: 'desc' }
      ],
      take: limit
    });
    
    return chunks.map(chunk => new ConversationChunk({
      id: chunk.id,
      content: chunk.content,
      weekNumber: chunk.weekNumber,
      timestamp: chunk.timestamp,
      keywords: chunk.keywords,
      createdAt: chunk.createdAt
    }));
  }

  static async delete(id) {
    await prisma.conversationChunk.delete({
      where: { id }
    });
  }

  static async clearAll() {
    await prisma.conversationChunk.deleteMany();
  }

  toJSON() {
    return {
      id: this.id,
      content: this.content,
      weekNumber: this.weekNumber,
      timestamp: this.timestamp,
      keywords: this.keywords,
      createdAt: this.createdAt
    };
  }
}

module.exports = ConversationChunk;

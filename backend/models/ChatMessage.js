const prisma = require('../lib/prisma');
const { v4: uuidv4 } = require('uuid');

class ChatMessage {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.content = data.content;
    this.type = data.type; // 'user' or 'assistant'
    this.timestamp = data.timestamp || new Date();
    this.context = data.context;
    this.isError = data.isError || false;
    this.isDiagnostic = data.isDiagnostic || false;
    this.diagnosticQuestions = data.diagnosticQuestions;
    this.diagnosticAnswers = data.diagnosticAnswers;
    this.parentMessageId = data.parentMessageId;
    this.sessionId = data.sessionId;
    this.createdAt = data.createdAt || new Date();
  }

  async save() {
    const data = {
      id: this.id,
      content: this.content,
      type: this.type,
      timestamp: this.timestamp,
      context: this.context,
      isError: this.isError,
      isDiagnostic: this.isDiagnostic,
      diagnosticQuestions: this.diagnosticQuestions,
      diagnosticAnswers: this.diagnosticAnswers,
      parentMessageId: this.parentMessageId,
      sessionId: this.sessionId,
    };

    // Always create new message (since we auto-generate IDs)
    const created = await prisma.chatMessage.create({
      data: data,
    });
    return new ChatMessage(created);
  }

  static async getAll() {
    const messages = await prisma.chatMessage.findMany({
      orderBy: { timestamp: 'asc' },
    });
    
    return messages.map(message => new ChatMessage(message));
  }

  static async getById(id) {
    const message = await prisma.chatMessage.findUnique({
      where: { id },
    });
    
    if (message) {
      return new ChatMessage(message);
    }
    
    return null;
  }

  static async getRecent(limit = 50) {
    const messages = await prisma.chatMessage.findMany({
      orderBy: { timestamp: 'desc' },
      take: limit,
    });
    
    return messages.reverse().map(message => new ChatMessage(message));
  }

  static async getBySessionId(sessionId) {
    const messages = await prisma.chatMessage.findMany({
      where: { sessionId },
      orderBy: { timestamp: 'asc' },
    });
    
    return messages.map(message => new ChatMessage(message));
  }

  static async clearHistory() {
    await prisma.chatMessage.deleteMany();
  }

  static async delete(id) {
    await prisma.chatMessage.delete({
      where: { id },
    });
  }

  toJSON() {
    return {
      id: this.id,
      content: this.content,
      type: this.type,
      timestamp: this.timestamp,
      context: this.context,
      isError: this.isError,
      isDiagnostic: this.isDiagnostic,
      diagnosticQuestions: this.diagnosticQuestions,
      diagnosticAnswers: this.diagnosticAnswers,
      parentMessageId: this.parentMessageId,
      createdAt: this.createdAt
    };
  }
}

module.exports = ChatMessage;
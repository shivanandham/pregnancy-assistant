const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class ChatMessage {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.content = data.content;
    this.type = data.type; // 'user' or 'assistant'
    this.timestamp = data.timestamp || new Date().toISOString();
    this.context = data.context || null;
    this.isError = data.isError || false;
    this.isDiagnostic = data.isDiagnostic || false;
    this.diagnosticQuestions = data.diagnosticQuestions || null;
    this.diagnosticAnswers = data.diagnosticAnswers || null;
    this.parentMessageId = data.parentMessageId || null;
  }

  async save() {
    const sql = `
      INSERT INTO chat_messages 
      (id, content, type, timestamp, context, is_error, is_diagnostic, diagnostic_questions, diagnostic_answers, parent_message_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.content,
      this.type,
      this.timestamp,
      this.context,
      this.isError ? 1 : 0,
      this.isDiagnostic ? 1 : 0,
      this.diagnosticQuestions ? JSON.stringify(this.diagnosticQuestions) : null,
      this.diagnosticAnswers ? JSON.stringify(this.diagnosticAnswers) : null,
      this.parentMessageId
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM chat_messages ORDER BY timestamp ASC';
    const rows = await database.all(sql);
    
    return rows.map(row => new ChatMessage({
      id: row.id,
      content: row.content,
      type: row.type,
      timestamp: row.timestamp,
      context: row.context,
      isError: Boolean(row.is_error),
      isDiagnostic: Boolean(row.is_diagnostic),
      diagnosticQuestions: row.diagnostic_questions ? JSON.parse(row.diagnostic_questions) : null,
      diagnosticAnswers: row.diagnostic_answers ? JSON.parse(row.diagnostic_answers) : null,
      parentMessageId: row.parent_message_id
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM chat_messages WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new ChatMessage({
        id: row.id,
        content: row.content,
        type: row.type,
        timestamp: row.timestamp,
        context: row.context,
        isError: Boolean(row.is_error)
      });
    }
    
    return null;
  }

  static async getRecent(limit = 50) {
    const sql = `
      SELECT * FROM chat_messages 
      ORDER BY timestamp DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [limit]);
    
    return rows.map(row => new ChatMessage({
      id: row.id,
      content: row.content,
      type: row.type,
      timestamp: row.timestamp,
      context: row.context,
      isError: Boolean(row.is_error)
    })).reverse(); // Reverse to get chronological order
  }

  static async clearHistory() {
    const sql = 'DELETE FROM chat_messages';
    await database.run(sql);
  }

  static async delete(id) {
    const sql = 'DELETE FROM chat_messages WHERE id = ?';
    await database.run(sql, [id]);
  }

  toJSON() {
    return {
      id: this.id,
      content: this.content,
      type: this.type,
      timestamp: this.timestamp,
      context: this.context,
      isError: this.isError
    };
  }
}

module.exports = ChatMessage;

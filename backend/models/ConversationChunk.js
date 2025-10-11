const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

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
    const sql = `
      INSERT INTO conversation_chunks 
      (id, content, week_number, timestamp, keywords, created_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.content,
      this.weekNumber,
      this.timestamp,
      this.keywords,
      this.createdAt
    ]);
    
    // Also insert into FTS table
    const ftsSql = `
      INSERT INTO conversation_chunks_fts (content, keywords)
      VALUES (?, ?)
    `;
    
    await database.run(ftsSql, [
      this.content,
      this.keywords
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM conversation_chunks ORDER BY timestamp DESC';
    const rows = await database.all(sql);
    
    return rows.map(row => new ConversationChunk({
      id: row.id,
      content: row.content,
      weekNumber: row.week_number,
      timestamp: row.timestamp,
      keywords: row.keywords,
      createdAt: row.created_at
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM conversation_chunks WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new ConversationChunk({
        id: row.id,
        content: row.content,
        weekNumber: row.week_number,
        timestamp: row.timestamp,
        keywords: row.keywords,
        createdAt: row.created_at
      });
    }
    
    return null;
  }

  static async search(query, limit = 20) {
    // For now, use simple LIKE search until we implement proper FTS
    const sql = `
      SELECT * FROM conversation_chunks 
      WHERE content LIKE ? OR keywords LIKE ?
      ORDER BY timestamp DESC
      LIMIT ?
    `;
    
    const searchTerm = `%${query}%`;
    const rows = await database.all(sql, [searchTerm, searchTerm, limit]);
    
    return rows.map(row => new ConversationChunk({
      id: row.id,
      content: row.content,
      weekNumber: row.week_number,
      timestamp: row.timestamp,
      keywords: row.keywords,
      createdAt: row.created_at
    }));
  }

  static async getRecent(limit = 50) {
    const sql = `
      SELECT * FROM conversation_chunks 
      ORDER BY timestamp DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [limit]);
    
    return rows.map(row => new ConversationChunk({
      id: row.id,
      content: row.content,
      weekNumber: row.week_number,
      timestamp: row.timestamp,
      keywords: row.keywords,
      createdAt: row.created_at
    }));
  }

  static async getByWeek(week, limit = 20) {
    const sql = `
      SELECT * FROM conversation_chunks 
      WHERE week_number = ?
      ORDER BY timestamp DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [week, limit]);
    
    return rows.map(row => new ConversationChunk({
      id: row.id,
      content: row.content,
      weekNumber: row.week_number,
      timestamp: row.timestamp,
      keywords: row.keywords,
      createdAt: row.created_at
    }));
  }

  static async getByWeekRange(startWeek, endWeek, limit = 50) {
    const sql = `
      SELECT * FROM conversation_chunks 
      WHERE week_number >= ? AND week_number <= ?
      ORDER BY week_number ASC, timestamp DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [startWeek, endWeek, limit]);
    
    return rows.map(row => new ConversationChunk({
      id: row.id,
      content: row.content,
      weekNumber: row.week_number,
      timestamp: row.timestamp,
      keywords: row.keywords,
      createdAt: row.created_at
    }));
  }

  static async delete(id) {
    // Delete from main table
    const sql = 'DELETE FROM conversation_chunks WHERE id = ?';
    await database.run(sql, [id]);
    
    // Note: FTS table cleanup would need to be handled differently
    // For now, we'll rely on the main table deletion
  }

  static async clearAll() {
    await database.run('DELETE FROM conversation_chunks');
    await database.run('DELETE FROM conversation_chunks_fts');
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

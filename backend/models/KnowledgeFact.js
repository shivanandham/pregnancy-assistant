const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class KnowledgeFact {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.category = data.category; // 'symptom', 'milestone', 'preference', 'medical', 'activity'
    this.factText = data.factText;
    this.sourceMessageId = data.sourceMessageId || null;
    this.weekNumber = data.weekNumber || null;
    this.dateRecorded = data.dateRecorded || new Date().toISOString();
    this.metadata = data.metadata ? JSON.stringify(data.metadata) : null;
    this.createdAt = data.createdAt || new Date().toISOString();
  }

  async save() {
    const sql = `
      INSERT INTO knowledge_facts 
      (id, category, fact_text, source_message_id, week_number, date_recorded, metadata, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.category,
      this.factText,
      this.sourceMessageId,
      this.weekNumber,
      this.dateRecorded,
      this.metadata,
      this.createdAt
    ]);
    
    // Also insert into FTS table
    const ftsSql = `
      INSERT INTO knowledge_facts_fts (fact_text, category)
      VALUES (?, ?)
    `;
    
    await database.run(ftsSql, [
      this.factText,
      this.category
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM knowledge_facts ORDER BY created_at DESC';
    const rows = await database.all(sql);
    
    return rows.map(row => new KnowledgeFact({
      id: row.id,
      category: row.category,
      factText: row.fact_text,
      sourceMessageId: row.source_message_id,
      weekNumber: row.week_number,
      dateRecorded: row.date_recorded,
      metadata: row.metadata ? JSON.parse(row.metadata) : null,
      createdAt: row.created_at
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM knowledge_facts WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new KnowledgeFact({
        id: row.id,
        category: row.category,
        factText: row.fact_text,
        sourceMessageId: row.source_message_id,
        weekNumber: row.week_number,
        dateRecorded: row.date_recorded,
        metadata: row.metadata ? JSON.parse(row.metadata) : null,
        createdAt: row.created_at
      });
    }
    
    return null;
  }

  static async search(query, limit = 20) {
    // For now, use simple LIKE search until we implement proper FTS
    const sql = `
      SELECT * FROM knowledge_facts 
      WHERE fact_text LIKE ? OR category LIKE ?
      ORDER BY created_at DESC
      LIMIT ?
    `;
    
    const searchTerm = `%${query}%`;
    const rows = await database.all(sql, [searchTerm, searchTerm, limit]);
    
    return rows.map(row => new KnowledgeFact({
      id: row.id,
      category: row.category,
      factText: row.fact_text,
      sourceMessageId: row.source_message_id,
      weekNumber: row.week_number,
      dateRecorded: row.date_recorded,
      metadata: row.metadata ? JSON.parse(row.metadata) : null,
      createdAt: row.created_at
    }));
  }

  static async getByCategory(category, limit = 50) {
    const sql = `
      SELECT * FROM knowledge_facts 
      WHERE category = ? 
      ORDER BY created_at DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [category, limit]);
    
    return rows.map(row => new KnowledgeFact({
      id: row.id,
      category: row.category,
      factText: row.fact_text,
      sourceMessageId: row.source_message_id,
      weekNumber: row.week_number,
      dateRecorded: row.date_recorded,
      metadata: row.metadata ? JSON.parse(row.metadata) : null,
      createdAt: row.created_at
    }));
  }

  static async getByWeekRange(startWeek, endWeek, limit = 50) {
    const sql = `
      SELECT * FROM knowledge_facts 
      WHERE week_number >= ? AND week_number <= ?
      ORDER BY week_number ASC, created_at DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [startWeek, endWeek, limit]);
    
    return rows.map(row => new KnowledgeFact({
      id: row.id,
      category: row.category,
      factText: row.fact_text,
      sourceMessageId: row.source_message_id,
      weekNumber: row.week_number,
      dateRecorded: row.date_recorded,
      metadata: row.metadata ? JSON.parse(row.metadata) : null,
      createdAt: row.created_at
    }));
  }

  static async getRecent(limit = 20) {
    const sql = `
      SELECT * FROM knowledge_facts 
      ORDER BY created_at DESC 
      LIMIT ?
    `;
    const rows = await database.all(sql, [limit]);
    
    return rows.map(row => new KnowledgeFact({
      id: row.id,
      category: row.category,
      factText: row.fact_text,
      sourceMessageId: row.source_message_id,
      weekNumber: row.week_number,
      dateRecorded: row.date_recorded,
      metadata: row.metadata ? JSON.parse(row.metadata) : null,
      createdAt: row.created_at
    }));
  }

  static async delete(id) {
    // Delete from main table
    const sql = 'DELETE FROM knowledge_facts WHERE id = ?';
    await database.run(sql, [id]);
    
    // Note: FTS table cleanup would need to be handled differently
    // For now, we'll rely on the main table deletion
  }

  static async clearAll() {
    await database.run('DELETE FROM knowledge_facts');
    await database.run('DELETE FROM knowledge_facts_fts');
  }

  toJSON() {
    return {
      id: this.id,
      category: this.category,
      factText: this.factText,
      sourceMessageId: this.sourceMessageId,
      weekNumber: this.weekNumber,
      dateRecorded: this.dateRecorded,
      metadata: this.metadata ? JSON.parse(this.metadata) : null,
      createdAt: this.createdAt
    };
  }
}

module.exports = KnowledgeFact;

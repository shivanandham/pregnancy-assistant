const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');
const Logger = require('../middleware/logger');

class Symptom {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.type = data.type;
    this.severity = data.severity;
    this.dateTime = data.dateTime;
    this.notes = data.notes || null;
    this.customType = data.customType || null;
    this.createdAt = data.createdAt || new Date().toISOString();
  }

  getDisplayName() {
    if (this.type === 'other' && this.customType) {
      return this.customType;
    }
    return this.type.replace(/([A-Z])/g, ' $1').trim();
  }

  async save() {
    const sql = `
      INSERT INTO symptoms 
      (id, type, severity, date_time, notes, custom_type, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.type,
      this.severity,
      this.dateTime,
      this.notes,
      this.customType,
      this.createdAt
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM symptoms ORDER BY date_time DESC';
    const rows = await database.all(sql);
    
    return rows.map(row => new Symptom({
      id: row.id,
      type: row.type,
      severity: row.severity,
      dateTime: row.date_time,
      notes: row.notes,
      customType: row.custom_type,
      createdAt: row.created_at
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM symptoms WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new Symptom({
        id: row.id,
        type: row.type,
        severity: row.severity,
        dateTime: row.date_time,
        notes: row.notes,
        customType: row.custom_type,
        createdAt: row.created_at
      });
    }
    
    return null;
  }

  static async getByDateRange(startDate, endDate) {
    const sql = `
      SELECT * FROM symptoms 
      WHERE date_time >= ? AND date_time <= ? 
      ORDER BY date_time DESC
    `;
    const rows = await database.all(sql, [startDate, endDate]);
    
    return rows.map(row => new Symptom({
      id: row.id,
      type: row.type,
      severity: row.severity,
      dateTime: row.date_time,
      notes: row.notes,
      customType: row.custom_type,
      createdAt: row.created_at
    }));
  }

  static async delete(id) {
    const sql = 'DELETE FROM symptoms WHERE id = ?';
    await database.run(sql, [id]);
  }

  toJSON() {
    return {
      id: this.id,
      type: this.type,
      severity: this.severity,
      dateTime: this.dateTime,
      notes: this.notes,
      customType: this.customType,
      createdAt: this.createdAt,
      displayName: this.getDisplayName()
    };
  }
}

module.exports = Symptom;

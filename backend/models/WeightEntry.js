const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class WeightEntry {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.weight = data.weight;
    this.dateTime = data.dateTime;
    this.notes = data.notes || null;
    this.createdAt = data.createdAt || new Date().toISOString();
  }

  // Convert kg to lbs
  getWeightInPounds() {
    return this.weight * 2.20462;
  }

  async save() {
    const sql = `
      INSERT INTO weight_entries 
      (id, weight, date_time, notes, created_at)
      VALUES (?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.weight,
      this.dateTime,
      this.notes,
      this.createdAt
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM weight_entries ORDER BY date_time DESC';
    const rows = await database.all(sql);
    
    return rows.map(row => new WeightEntry({
      id: row.id,
      weight: row.weight,
      dateTime: row.date_time,
      notes: row.notes,
      createdAt: row.created_at
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM weight_entries WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new WeightEntry({
        id: row.id,
        weight: row.weight,
        dateTime: row.date_time,
        notes: row.notes,
        createdAt: row.created_at
      });
    }
    
    return null;
  }

  static async getByDateRange(startDate, endDate) {
    const sql = `
      SELECT * FROM weight_entries 
      WHERE date_time >= ? AND date_time <= ? 
      ORDER BY date_time DESC
    `;
    const rows = await database.all(sql, [startDate, endDate]);
    
    return rows.map(row => new WeightEntry({
      id: row.id,
      weight: row.weight,
      dateTime: row.date_time,
      notes: row.notes,
      createdAt: row.created_at
    }));
  }

  static async delete(id) {
    const sql = 'DELETE FROM weight_entries WHERE id = ?';
    await database.run(sql, [id]);
  }

  toJSON() {
    return {
      id: this.id,
      weight: this.weight,
      dateTime: this.dateTime,
      notes: this.notes,
      createdAt: this.createdAt,
      weightInPounds: this.getWeightInPounds()
    };
  }
}

module.exports = WeightEntry;

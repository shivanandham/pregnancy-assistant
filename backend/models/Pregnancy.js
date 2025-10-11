const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class Pregnancy {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.dueDate = data.dueDate;
    this.lastMenstrualPeriod = data.lastMenstrualPeriod;
    this.notes = data.notes || null;
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  // Calculate current week of pregnancy
  getCurrentWeek() {
    const now = new Date();
    const lmp = new Date(this.lastMenstrualPeriod);
    const daysSinceLMP = Math.floor((now - lmp) / (1000 * 60 * 60 * 24));
    return Math.floor(daysSinceLMP / 7) + 1;
  }

  // Calculate days until due date
  getDaysUntilDueDate() {
    const now = new Date();
    const dueDate = new Date(this.dueDate);
    return Math.ceil((dueDate - now) / (1000 * 60 * 60 * 24));
  }

  // Get current trimester
  getCurrentTrimester() {
    const week = this.getCurrentWeek();
    if (week <= 12) return 1;
    if (week <= 28) return 2;
    return 3;
  }

  // Get progress percentage
  getProgressPercentage() {
    const lmp = new Date(this.lastMenstrualPeriod);
    const dueDate = new Date(this.dueDate);
    const now = new Date();
    const totalDays = Math.floor((dueDate - lmp) / (1000 * 60 * 60 * 24));
    const elapsedDays = Math.floor((now - lmp) / (1000 * 60 * 60 * 24));
    return Math.min(Math.max(elapsedDays / totalDays, 0), 1);
  }

  async save() {
    const sql = `
      INSERT OR REPLACE INTO pregnancy_data 
      (id, due_date, last_menstrual_period, notes, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.dueDate,
      this.lastMenstrualPeriod,
      this.notes,
      this.createdAt,
      this.updatedAt
    ]);
    
    return this;
  }

  static async getCurrent() {
    const sql = 'SELECT * FROM pregnancy_data ORDER BY created_at DESC LIMIT 1';
    const row = await database.get(sql);
    
    if (row) {
      return new Pregnancy({
        id: row.id,
        dueDate: row.due_date,
        lastMenstrualPeriod: row.last_menstrual_period,
        notes: row.notes,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      });
    }
    
    return null;
  }

  static async delete(id) {
    const sql = 'DELETE FROM pregnancy_data WHERE id = ?';
    await database.run(sql, [id]);
  }

  toJSON() {
    return {
      id: this.id,
      dueDate: this.dueDate,
      lastMenstrualPeriod: this.lastMenstrualPeriod,
      notes: this.notes,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      currentWeek: this.getCurrentWeek(),
      daysUntilDueDate: this.getDaysUntilDueDate(),
      currentTrimester: this.getCurrentTrimester(),
      progressPercentage: this.getProgressPercentage()
    };
  }
}

module.exports = Pregnancy;

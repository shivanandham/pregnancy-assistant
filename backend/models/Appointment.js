const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class Appointment {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.title = data.title;
    this.type = data.type;
    this.dateTime = data.dateTime;
    this.location = data.location || null;
    this.doctor = data.doctor || null;
    this.notes = data.notes || null;
    this.isCompleted = data.isCompleted || false;
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  getDisplayName() {
    return this.type.replace(/([A-Z])/g, ' $1').trim();
  }

  isUpcoming() {
    const now = new Date();
    const appointmentDate = new Date(this.dateTime);
    return appointmentDate > now && !this.isCompleted;
  }

  isPast() {
    const now = new Date();
    const appointmentDate = new Date(this.dateTime);
    return appointmentDate < now || this.isCompleted;
  }

  async save() {
    const sql = `
      INSERT OR REPLACE INTO appointments 
      (id, title, type, date_time, location, doctor, notes, is_completed, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.title,
      this.type,
      this.dateTime,
      this.location,
      this.doctor,
      this.notes,
      this.isCompleted ? 1 : 0,
      this.createdAt,
      this.updatedAt
    ]);
    
    return this;
  }

  static async getAll() {
    const sql = 'SELECT * FROM appointments ORDER BY date_time ASC';
    const rows = await database.all(sql);
    
    return rows.map(row => new Appointment({
      id: row.id,
      title: row.title,
      type: row.type,
      dateTime: row.date_time,
      location: row.location,
      doctor: row.doctor,
      notes: row.notes,
      isCompleted: Boolean(row.is_completed),
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
  }

  static async getById(id) {
    const sql = 'SELECT * FROM appointments WHERE id = ?';
    const row = await database.get(sql, [id]);
    
    if (row) {
      return new Appointment({
        id: row.id,
        title: row.title,
        type: row.type,
        dateTime: row.date_time,
        location: row.location,
        doctor: row.doctor,
        notes: row.notes,
        isCompleted: Boolean(row.is_completed),
        createdAt: row.created_at,
        updatedAt: row.updated_at
      });
    }
    
    return null;
  }

  static async getUpcoming() {
    const now = new Date().toISOString();
    const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
    
    const sql = `
      SELECT * FROM appointments 
      WHERE date_time >= ? AND date_time <= ? AND is_completed = 0
      ORDER BY date_time ASC
    `;
    const rows = await database.all(sql, [now, nextWeek]);
    
    return rows.map(row => new Appointment({
      id: row.id,
      title: row.title,
      type: row.type,
      dateTime: row.date_time,
      location: row.location,
      doctor: row.doctor,
      notes: row.notes,
      isCompleted: Boolean(row.is_completed),
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));
  }

  static async delete(id) {
    const sql = 'DELETE FROM appointments WHERE id = ?';
    await database.run(sql, [id]);
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      dateTime: this.dateTime,
      location: this.location,
      doctor: this.doctor,
      notes: this.notes,
      isCompleted: this.isCompleted,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      displayName: this.getDisplayName(),
      isUpcoming: this.isUpcoming(),
      isPast: this.isPast()
    };
  }
}

module.exports = Appointment;

const sqlite3 = require('sqlite3').verbose();
const path = require('path');

class Database {
  constructor() {
    this.db = null;
  }

  async initialize() {
    return new Promise((resolve, reject) => {
      const dbPath = path.join(__dirname, '..', 'data', 'pregnancy_assistant.db');
      
      this.db = new sqlite3.Database(dbPath, (err) => {
        if (err) {
          console.error('Error opening database:', err.message);
          reject(err);
        } else {
          console.log('Connected to SQLite database');
          this.createTables().then(resolve).catch(reject);
        }
      });
    });
  }

  async createTables() {
    const tables = [
      // User profile table
      `CREATE TABLE IF NOT EXISTS user_profiles (
        id TEXT PRIMARY KEY,
        height REAL,
        weight REAL,
        pre_pregnancy_weight REAL,
        age INTEGER,
        gender TEXT DEFAULT 'female',
        locality TEXT,
        timezone TEXT,
        medical_history TEXT,
        allergies TEXT,
        medications TEXT,
        lifestyle TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Pregnancy data table
      `CREATE TABLE IF NOT EXISTS pregnancy_data (
        id TEXT PRIMARY KEY,
        due_date TEXT NOT NULL,
        last_menstrual_period TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Symptoms table
      `CREATE TABLE IF NOT EXISTS symptoms (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        severity TEXT NOT NULL,
        date_time TEXT NOT NULL,
        notes TEXT,
        custom_type TEXT,
        created_at TEXT NOT NULL
      )`,

      // Appointments table
      `CREATE TABLE IF NOT EXISTS appointments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        date_time TEXT NOT NULL,
        location TEXT,
        doctor TEXT,
        notes TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Weight entries table
      `CREATE TABLE IF NOT EXISTS weight_entries (
        id TEXT PRIMARY KEY,
        weight REAL NOT NULL,
        date_time TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )`,

      // Chat messages table
      `CREATE TABLE IF NOT EXISTS chat_messages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        context TEXT,
        is_error INTEGER DEFAULT 0
      )`,

      // Reminders table
      `CREATE TABLE IF NOT EXISTS reminders (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date_time TEXT NOT NULL,
        type TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )`,

      // Knowledge facts table - structured extracted information
      `CREATE TABLE IF NOT EXISTS knowledge_facts (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        fact_text TEXT NOT NULL,
        source_message_id TEXT,
        week_number INTEGER,
        date_recorded TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT NOT NULL
      )`,

      // Conversation chunks table - contextual conversation storage
      `CREATE TABLE IF NOT EXISTS conversation_chunks (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        week_number INTEGER,
        timestamp TEXT NOT NULL,
        keywords TEXT,
        created_at TEXT NOT NULL
      )`,

      // Enable FTS5 for full-text search on knowledge facts
      `CREATE VIRTUAL TABLE IF NOT EXISTS knowledge_facts_fts USING fts5(
        fact_text, category
      )`,

      // Enable FTS5 for full-text search on conversation chunks
      `CREATE VIRTUAL TABLE IF NOT EXISTS conversation_chunks_fts USING fts5(
        content, keywords
      )`
    ];

    for (const table of tables) {
      await this.run(table);
    }
  }

  run(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.run(sql, params, function(err) {
        if (err) {
          reject(err);
        } else {
          resolve({ id: this.lastID, changes: this.changes });
        }
      });
    });
  }

  get(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.get(sql, params, (err, row) => {
        if (err) {
          reject(err);
        } else {
          resolve(row);
        }
      });
    });
  }

  all(sql, params = []) {
    return new Promise((resolve, reject) => {
      this.db.all(sql, params, (err, rows) => {
        if (err) {
          reject(err);
        } else {
          resolve(rows);
        }
      });
    });
  }

  close() {
    return new Promise((resolve, reject) => {
      this.db.close((err) => {
        if (err) {
          reject(err);
        } else {
          console.log('Database connection closed');
          resolve();
        }
      });
    });
  }
}

module.exports = new Database();

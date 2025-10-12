require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const { Pool } = require('pg');

class SupabaseDatabase {
  constructor() {
    this.supabaseUrl = process.env.SUPABASE_URL;
    this.supabaseKey = process.env.SUPABASE_ANON_KEY;
    this.supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    this.supabaseDbPassword = process.env.SUPABASE_DB_PASSWORD;
    
    if (!this.supabaseUrl || !this.supabaseKey) {
      throw new Error('Supabase URL and key are required');
    }

    // Initialize Supabase client
    this.supabase = createClient(this.supabaseUrl, this.supabaseKey);
    
    // Construct database URL from environment variables
    const projectRef = this.extractProjectRef(this.supabaseUrl);
    const databaseUrl = `postgresql://postgres:${this.supabaseDbPassword}@db.${projectRef}.supabase.co:5432/postgres`;
    
    // Initialize PostgreSQL connection for direct queries
    this.pool = new Pool({
      connectionString: databaseUrl,
      ssl: { rejectUnauthorized: false }
    });
  }

  extractProjectRef(url) {
    // Extract project reference from Supabase URL
    // URL format: https://abcdefghijklmnop.supabase.co
    const match = url.match(/https:\/\/([^.]+)\.supabase\.co/);
    if (!match) {
      throw new Error('Invalid Supabase URL format');
    }
    return match[1];
  }

  async initialize() {
    try {
      console.log('🔗 Connecting to Supabase...');
      
      // Test connection
      const { data, error } = await this.supabase
        .from('pregnancy_data')
        .select('count')
        .limit(1);
      
      if (error && error.code !== 'PGRST116') { // PGRST116 = table doesn't exist
        throw error;
      }
      
      console.log('✅ Connected to Supabase successfully');
      return true;
    } catch (error) {
      console.error('❌ Failed to connect to Supabase:', error.message);
      throw error;
    }
  }

  async run(sql, params = []) {
    try {
      const result = await this.pool.query(sql, params);
      return result;
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  async get(sql, params = []) {
    try {
      const result = await this.pool.query(sql, params);
      return result.rows[0] || null;
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  async all(sql, params = []) {
    try {
      const result = await this.pool.query(sql, params);
      return result.rows;
    } catch (error) {
      console.error('Database query error:', error);
      throw error;
    }
  }

  async close() {
    try {
      await this.pool.end();
      console.log('✅ Supabase connection closed');
    } catch (error) {
      console.error('❌ Error closing Supabase connection:', error);
    }
  }

  // Supabase client for advanced operations
  get client() {
    return this.supabase;
  }
}

// Create singleton instance
const database = new SupabaseDatabase();

module.exports = database;

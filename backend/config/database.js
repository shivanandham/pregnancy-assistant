require('dotenv').config();

class DatabaseConfig {
  static getDatabaseUrl() {
    const isDevelopment = process.env.NODE_ENV === 'development';
    
    if (isDevelopment) {
      // Local PostgreSQL for development
      const host = process.env.LOCAL_DB_HOST || 'localhost';
      const port = process.env.LOCAL_DB_PORT || 5432;
      const database = process.env.LOCAL_DB_NAME || 'luma';
      const user = process.env.LOCAL_DB_USER || 'postgres';
      const password = process.env.LOCAL_DB_PASSWORD || 'postgres';
      
      return `postgresql://${user}:${password}@${host}:${port}/${database}`;
    } else {
      // Supabase for production
      const supabaseUrl = process.env.SUPABASE_URL;
      const supabaseDbPassword = process.env.SUPABASE_DB_PASSWORD;
      
      if (!supabaseUrl || !supabaseDbPassword) {
        throw new Error('Supabase URL and password are required for production');
      }

      const projectRef = this.extractProjectRef(supabaseUrl);
      // Use session pooler for IPv4 compatibility
      return `postgresql://postgres.${projectRef}:${supabaseDbPassword}@aws-1-us-east-2.pooler.supabase.com:5432/postgres`;
    }
  }

  static extractProjectRef(url) {
    const match = url.match(/https:\/\/([^.]+)\.supabase\.co/);
    if (!match) {
      throw new Error('Invalid Supabase URL format');
    }
    return match[1];
  }

  static getEnvironmentInfo() {
    const isDevelopment = process.env.NODE_ENV === 'development';
    const databaseUrl = this.getDatabaseUrl();
    
    return {
      environment: isDevelopment ? 'development' : 'production',
      database: isDevelopment ? 'Local PostgreSQL' : 'Supabase PostgreSQL',
      url: databaseUrl.replace(/\/\/.*@/, '//***:***@') // Hide credentials in logs
    };
  }
}

module.exports = DatabaseConfig;
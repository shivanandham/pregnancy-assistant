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
      // Self-hosted PostgreSQL on DigitalOcean for production
      const host = process.env.PROD_DB_HOST || 'localhost';
      const port = process.env.PROD_DB_PORT || 5432;
      const database = process.env.PROD_DB_NAME || 'pregnancy_assistant';
      const user = process.env.PROD_DB_USER || 'postgres';
      const password = process.env.PROD_DB_PASSWORD;
      
      if (!password) {
        throw new Error('PROD_DB_PASSWORD is required for production');
      }
      
      return `postgresql://${user}:${password}@${host}:${port}/${database}`;
    }
  }

  static getEnvironmentInfo() {
    const isDevelopment = process.env.NODE_ENV === 'development';
    const databaseUrl = this.getDatabaseUrl();
    
    return {
      environment: isDevelopment ? 'development' : 'production',
      database: isDevelopment ? 'Local PostgreSQL' : 'Self-hosted PostgreSQL (DigitalOcean)',
      url: databaseUrl.replace(/\/\/.*@/, '//***:***@') // Hide credentials in logs
    };
  }
}

module.exports = DatabaseConfig;
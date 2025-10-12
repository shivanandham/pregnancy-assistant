const DatabaseConfig = require('../config/database');
const fs = require('fs');
const path = require('path');

function setDatabaseUrl() {
  try {
    console.log('🔍 DEBUG: setDatabaseUrl() function called');
    console.log('🔍 DEBUG: NODE_ENV in setDatabaseUrl =', process.env.NODE_ENV);
    
    const databaseUrl = DatabaseConfig.getDatabaseUrl();
    const envInfo = DatabaseConfig.getEnvironmentInfo();
    
    console.log(`🔧 Setting DATABASE_URL for ${envInfo.environment} environment`);
    console.log(`📊 Using: ${envInfo.database}`);
    console.log(`🔗 URL: ${envInfo.url}`);
    
    // Read current .env file
    const envPath = path.join(__dirname, '..', '.env');
    let envContent = fs.readFileSync(envPath, 'utf8');
    
    // Update or add DATABASE_URL
    if (envContent.includes('DATABASE_URL=')) {
      envContent = envContent.replace(
        /DATABASE_URL=.*/,
        `DATABASE_URL="${databaseUrl}"`
      );
    } else {
      envContent += `\nDATABASE_URL="${databaseUrl}"\n`;
    }
    
    // Write back to .env file
    fs.writeFileSync(envPath, envContent);
    
    console.log('✅ DATABASE_URL updated successfully');
    
    // Set environment variable for current process
    process.env.DATABASE_URL = databaseUrl;
    
    return databaseUrl;
  } catch (error) {
    console.error('❌ Failed to set DATABASE_URL:', error.message);
    process.exit(1);
  }
}

// If this script is run directly
if (require.main === module) {
  setDatabaseUrl();
}

module.exports = setDatabaseUrl;

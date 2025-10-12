const database = require('./config/supabase');

async function migrateToSupabase() {
  try {
    console.log('🚀 Starting migration to Supabase...');
    
    // Test connection
    await database.initialize();
    
    console.log('✅ Migration completed successfully!');
    console.log('📝 Next steps:');
    console.log('1. Update your .env file with Supabase credentials');
    console.log('2. Run the SQL schema in your Supabase SQL editor');
    console.log('3. Update server.js to use Supabase instead of SQLite');
    console.log('4. Deploy to Railway with new environment variables');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
  } finally {
    await database.close();
  }
}

migrateToSupabase();

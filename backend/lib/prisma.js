const { PrismaClient } = require('@prisma/client');
const setDatabaseUrl = require('../scripts/set-database-url');

// Set the correct DATABASE_URL based on environment
if (process.env.NODE_ENV === 'production') {
  // In production, set DATABASE_URL directly from environment variables
  const DatabaseConfig = require('../config/database');
  process.env.DATABASE_URL = DatabaseConfig.getDatabaseUrl();
} else {
  // In development, use the set-database-url script
  setDatabaseUrl();
}

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

// Handle graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

module.exports = prisma;

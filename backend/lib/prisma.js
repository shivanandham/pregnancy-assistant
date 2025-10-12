const { PrismaClient } = require('@prisma/client');
const setDatabaseUrl = require('../scripts/set-database-url');

// Set the correct DATABASE_URL based on environment
setDatabaseUrl();

const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

// Handle graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

module.exports = prisma;

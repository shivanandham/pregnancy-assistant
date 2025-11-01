const { PrismaClient } = require('@prisma/client');

// Prisma automatically reads DATABASE_URL from .env file (via dotenv)
// No need to set it manually - just ensure DATABASE_URL is in your .env file
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

// Handle graceful shutdown
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

module.exports = prisma;

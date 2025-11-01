#!/usr/bin/env node

/**
 * Database Connection Test
 * Simple test to verify database connectivity
 */

require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

// Prisma automatically reads DATABASE_URL from .env file
// Just verify it's set
if (!process.env.DATABASE_URL) {
  console.error('❌ DATABASE_URL is required in environment variables');
  console.error('Please set DATABASE_URL in your .env file');
  console.error('Example: DATABASE_URL=postgresql://postgres:password@localhost:5432/pregnancy_assistant');
  process.exit(1);
}

const prisma = new PrismaClient();

async function testConnection() {
  try {
    console.log('🧪 Testing database connection...');
    
    // Test basic connection
    const result = await prisma.$queryRaw`SELECT NOW() as current_time, current_database() as database_name`;
    console.log('✅ Connected successfully!');
    console.log(`   Database: ${result[0].database_name}`);
    console.log(`   Time: ${result[0].current_time}`);
    
    // Test table access
    const tableCount = await prisma.$queryRaw`
      SELECT COUNT(*) as count 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name NOT LIKE '_prisma_%'
    `;
    
    console.log(`✅ Tables accessible: ${tableCount[0].count} tables found`);
    
  } catch (error) {
    console.error('❌ Connection test failed:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

// Run the test
testConnection();

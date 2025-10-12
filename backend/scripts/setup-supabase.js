#!/usr/bin/env node

// Set up Supabase database schema
const { PrismaClient } = require('@prisma/client');
const setDatabaseUrl = require('./set-database-url');

async function setupSupabase() {
  try {
    console.log('🚀 Setting up Supabase database...');
    
    // Set NODE_ENV to production
    process.env.NODE_ENV = 'production';
    
    // Set the correct DATABASE_URL for Supabase
    setDatabaseUrl();
    
    const prisma = new PrismaClient();
    
    // Push schema to Supabase
    console.log('📋 Pushing schema to Supabase...');
    const { execSync } = require('child_process');
    execSync('npx prisma db push', { stdio: 'inherit' });
    
    console.log('✅ Supabase setup complete!');
    
    // Test connection
    console.log('🧪 Testing Supabase connection...');
    const result = await prisma.$queryRaw`SELECT NOW() as current_time`;
    console.log(`📅 Supabase time: ${result[0].current_time}`);
    
    await prisma.$disconnect();
    
  } catch (error) {
    console.error('❌ Supabase setup failed:', error.message);
    process.exit(1);
  }
}

setupSupabase();

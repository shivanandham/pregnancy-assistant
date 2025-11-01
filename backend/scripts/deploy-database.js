#!/usr/bin/env node

/**
 * Database Deployment Script
 * Automatically deploys database schema to self-hosted PostgreSQL production environment
 * 
 * Usage: node scripts/deploy-database.js
 */

require('dotenv').config();
const { execSync } = require('child_process');
const path = require('path');

class DatabaseDeployer {
  constructor() {
    this.isProduction = process.env.NODE_ENV === 'production';
    this.requiredEnvVars = [
      'DATABASE_URL'
    ];
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const prefix = {
      info: 'ℹ️',
      success: '✅',
      error: '❌',
      warning: '⚠️'
    }[type] || 'ℹ️';
    
    console.log(`${prefix} [${timestamp}] ${message}`);
  }

  checkEnvironment() {
    this.log('Checking environment configuration...');
    
    // Set production environment
    process.env.NODE_ENV = 'production';
    
    // Check if DATABASE_URL is set
    // Prisma will automatically read DATABASE_URL from .env file
    if (!process.env.DATABASE_URL) {
      this.log('DATABASE_URL environment variable is required', 'error');
      this.log('Please set DATABASE_URL in your .env file:', 'error');
      this.log('  DATABASE_URL=postgresql://user:password@host:port/database', 'error');
      this.log('', 'error');
      this.log('Example for local PostgreSQL on droplet:', 'error');
      this.log('  DATABASE_URL=postgresql://postgres:your_password@localhost:5432/pregnancy_assistant', 'error');
      process.exit(1);
    }
    
    // Log database host (for debugging, hide credentials)
    const dbUrl = process.env.DATABASE_URL;
    const hostMatch = dbUrl.match(/@([^:]+):/);
    const host = hostMatch ? hostMatch[1] : 'unknown';
    this.log(`DATABASE_URL found (host: ${host})`, 'success');
    this.log('Environment variables validated', 'success');
  }

  generatePrismaClient() {
    this.log('Generating Prisma client...');
    
    try {
      execSync('npx prisma generate', { 
        stdio: 'inherit',
        cwd: process.cwd()
      });
      this.log('Prisma client generated successfully', 'success');
    } catch (error) {
      this.log(`Failed to generate Prisma client: ${error.message}`, 'error');
      process.exit(1);
    }
  }

  deployMigrations() {
    this.log('Deploying database migrations...');
    
    try {
      execSync('npx prisma migrate deploy', { 
        stdio: 'inherit',
        cwd: process.cwd()
      });
      this.log('Database migrations deployed successfully', 'success');
    } catch (error) {
      this.log(`Failed to deploy migrations: ${error.message}`, 'error');
      process.exit(1);
    }
  }

  testConnection() {
    this.log('Testing database connection...');
    
    try {
      // Run the connection test
      const testScript = path.join(__dirname, 'test-connection.js');
      execSync(`node ${testScript}`, { 
        stdio: 'inherit',
        cwd: process.cwd()
      });
      this.log('Database connection test passed', 'success');
    } catch (error) {
      this.log(`Database connection test failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }

  async deploy() {
    try {
      this.log('🚀 Starting database deployment...');
      this.log(`Environment: ${process.env.NODE_ENV}`);
      
      // Step 1: Check environment (validates DATABASE_URL is set)
      this.checkEnvironment();
      
      // Step 2: Generate Prisma client
      this.generatePrismaClient();
      
      // Step 3: Deploy migrations
      // Note: Prisma will automatically read DATABASE_URL from .env file
      this.deployMigrations();
      
      // Step 4: Test connection
      this.testConnection();
      
      this.log('🎉 Database deployment completed successfully!', 'success');
      this.log('');
      this.log('📋 Next steps:');
      this.log('1. Your PostgreSQL database is ready for production');
      this.log('2. Deploy your backend to DigitalOcean');
      this.log('3. Update your Flutter app with the production API URL');
      this.log('4. Test your application end-to-end');
      
    } catch (error) {
      this.log(`Deployment failed: ${error.message}`, 'error');
      process.exit(1);
    }
  }
}

// Run deployment if this script is executed directly
if (require.main === module) {
  const deployer = new DatabaseDeployer();
  deployer.deploy();
}

module.exports = DatabaseDeployer;

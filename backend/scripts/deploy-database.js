#!/usr/bin/env node

/**
 * Database Deployment Script
 * Automatically deploys database schema to self-hosted PostgreSQL production environment
 * 
 * Usage: node scripts/deploy-database.js
 */

require('dotenv').config();
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

class DatabaseDeployer {
  constructor() {
    this.isProduction = process.env.NODE_ENV === 'production';
    this.requiredEnvVars = [
      'PROD_DB_HOST',
      'PROD_DB_PASSWORD'
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
    
    // Check required environment variables
    const missingVars = this.requiredEnvVars.filter(varName => !process.env[varName]);
    
    if (missingVars.length > 0) {
      this.log(`Missing required environment variables: ${missingVars.join(', ')}`, 'error');
      this.log('Please set these variables in your .env file:', 'error');
      missingVars.forEach(varName => {
        this.log(`  ${varName}=your_value_here`, 'error');
      });
      process.exit(1);
    }
    
    this.log('Environment variables validated', 'success');
  }

  updateDatabaseUrl() {
    this.log('Setting DATABASE_URL for production deployment...');
    
    try {
      // Set DATABASE_URL directly without modifying .env file
      const DatabaseConfig = require('../config/database');
      const databaseUrl = DatabaseConfig.getDatabaseUrl();
      
      // Set environment variable for current process only
      process.env.DATABASE_URL = databaseUrl;
      
      this.log('DATABASE_URL set for deployment (not saved to .env)', 'success');
    } catch (error) {
      this.log(`Failed to set DATABASE_URL: ${error.message}`, 'error');
      process.exit(1);
    }
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
      this.log(`Database Host: ${process.env.PROD_DB_HOST || 'localhost'}`);
      
      // Step 1: Check environment
      this.checkEnvironment();
      
      // Step 2: Update DATABASE_URL
      this.updateDatabaseUrl();
      
      // Step 3: Generate Prisma client
      this.generatePrismaClient();
      
      // Step 4: Deploy migrations
      this.deployMigrations();
      
      // Step 5: Test connection
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

#!/usr/bin/env node

const { execSync } = require('child_process');
const path = require('path');

async function runApiTests() {
  try {
    console.log('🧪 Running API tests with Newman...');
    
    const collectionPath = path.join(__dirname, '..', 'postman', 'Luma-Pregnancy-Assistant-API.postman_collection.json');
    const environmentPath = path.join(__dirname, '..', 'postman', 'Luma-Development.postman_environment.json');
    
    // Check if Newman is installed
    try {
      execSync('newman --version', { stdio: 'ignore' });
    } catch (error) {
      console.log('📦 Installing Newman...');
      execSync('npm install -g newman', { stdio: 'inherit' });
    }
    
    // Run the tests
    const command = `newman run "${collectionPath}" -e "${environmentPath}" --reporters cli,json --reporter-json-export test-results.json`;
    
    console.log('🚀 Starting API tests...');
    execSync(command, { stdio: 'inherit' });
    
    console.log('✅ API tests completed successfully!');
    console.log('📊 Test results saved to test-results.json');
    
  } catch (error) {
    console.error('❌ API tests failed:', error.message);
    process.exit(1);
  }
}

runApiTests();

#!/usr/bin/env node

/**
 * Generate Single Custom Token for Manual Testing
 * This creates one Firebase user and custom token for Postman testing
 * Custom tokens are verified by Firebase Admin SDK (same as ID tokens)
 */

require('dotenv').config();
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  const serviceAccount = {
    projectId: isDevelopment 
      ? process.env.FIREBASE_PROJECT_ID_DEV 
      : process.env.FIREBASE_PROJECT_ID_PROD,
    privateKey: (isDevelopment 
      ? process.env.FIREBASE_PRIVATE_KEY_DEV 
      : process.env.FIREBASE_PRIVATE_KEY_PROD)?.replace(/\\n/g, '\n'),
    clientEmail: isDevelopment 
      ? process.env.FIREBASE_CLIENT_EMAIL_DEV 
      : process.env.FIREBASE_CLIENT_EMAIL_PROD,
  };
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

async function generateToken() {
  try {
    console.log('🔧 Creating Firebase user for manual testing...');
    
    // Create a test user with unique email
    const timestamp = Date.now();
    const testUser = await admin.auth().createUser({
      email: `manual-test-${timestamp}@example.com`,
      displayName: 'Manual Test User',
      emailVerified: true,
      photoURL: 'https://example.com/test-avatar.jpg'
    });
    
    console.log('✅ Firebase user created:');
    console.log(`   UID: ${testUser.uid}`);
    console.log(`   Email: ${testUser.email}`);
    console.log(`   Name: ${testUser.displayName}`);
    
    // Generate custom token (for testing - will be verified by Firebase Admin SDK)
    const customToken = await admin.auth().createCustomToken(testUser.uid, {
      email: testUser.email,
      name: testUser.displayName,
      picture: testUser.photoURL
    });
    
    console.log('\n🎯 CUSTOM TOKEN FOR POSTMAN:');
    console.log('=' .repeat(60));
    console.log(customToken);
    console.log('=' .repeat(60));
    
    console.log('\n📋 POSTMAN SETUP:');
    console.log('1. Copy the token above');
    console.log('2. In Postman, go to your environment');
    console.log('3. Set "auth_token" variable to the token');
    console.log('4. Use {{auth_token}} in Authorization header');
    
    console.log('\n🧪 TESTING STEPS:');
    console.log('1. POST /api/auth/sync - Sync user to database');
    console.log('2. GET /api/pregnancy - Test protected endpoint');
    console.log('3. POST /api/pregnancy - Create pregnancy data');
    console.log('4. GET /api/pregnancy - Verify data creation');
    
    return {
      uid: testUser.uid,
      email: testUser.email,
      token: customToken
    };
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

generateToken().catch(console.error);

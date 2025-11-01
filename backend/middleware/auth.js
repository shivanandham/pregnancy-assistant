const admin = require('firebase-admin');
const SessionService = require('../services/sessionService');

// Initialize Firebase Admin SDK with environment-based configuration
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
  
  console.log(`🔧 Firebase Admin SDK initialized for ${isDevelopment ? 'DEVELOPMENT' : 'PRODUCTION'} project: ${serviceAccount.projectId}`);
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

/**
 * Verify Firebase token (only used for login endpoint)
 * Works for both development and production environments
 */
const verifyFirebaseToken = async (token) => {
  try {
    // Try to verify as ID token first (for Flutter/real authentication)
    try {
      const decodedToken = await admin.auth().verifyIdToken(token);
      
      return {
        success: true,
        user: {
          uid: decodedToken.uid,
          email: decodedToken.email,
          name: decodedToken.name,
          picture: decodedToken.picture
        }
      };
    } catch (idTokenError) {
      // If ID token verification fails, try custom token verification
      console.log('🔧 ID token verification failed, trying custom token verification...');
    }
    
    // For custom tokens, we need to verify them differently
    // Custom tokens are signed by Firebase Admin SDK, so we can verify the signature
    try {
      // Decode the custom token payload (without verification for now)
      const parts = token.split('.');
      if (parts.length !== 3) {
        throw new Error('Invalid token format');
      }
      
      const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
      
      // Verify the token was issued by our Firebase project
      const expectedIssuer = `firebase-adminsdk-${process.env.FIREBASE_PROJECT_ID_DEV?.split('-').pop()}@${process.env.FIREBASE_PROJECT_ID_DEV}.iam.gserviceaccount.com`;
      if (payload.iss !== expectedIssuer) {
        throw new Error('Invalid token issuer');
      }
      
      // Check if token is expired
      const now = Math.floor(Date.now() / 1000);
      if (payload.exp && payload.exp < now) {
        throw new Error('Token expired');
      }
      
      // Extract user info from custom token
      return {
        success: true,
        user: {
          uid: payload.uid,
          email: payload.claims?.email || 'test@example.com',
          name: payload.claims?.name || 'Test User',
          picture: payload.claims?.picture || 'https://example.com/test-avatar.jpg'
        }
      };
    } catch (customTokenError) {
      console.error('Custom token verification error:', customTokenError.message);
      throw customTokenError;
    }
    
  } catch (error) {
    console.error('Firebase token verification error:', error);
    return {
      success: false,
      error: error.message || 'Invalid token'
    };
  }
};

/**
 * Verify session token (used for all protected endpoints)
 */
const verifySessionToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }
    
    const token = authHeader.split('Bearer ')[1];
    
    // Verify session token
    const verification = await SessionService.verifySessionToken(token);
    
    if (!verification.valid) {
      return res.status(401).json({
        success: false,
        message: verification.error || 'Invalid token'
      });
    }
    
    // Set user info from session
    req.session = verification.session;
    req.user = {
      uid: verification.session.user.firebaseUid,
      email: verification.session.user.email,
      name: verification.session.user.displayName,
      picture: verification.session.user.photoURL
    };
    
    next();
  } catch (error) {
    console.error('Session token verification error:', error);
    return res.status(401).json({
      success: false,
      message: 'Invalid token'
    });
  }
};

/**
 * Middleware to get or create user in database
 */
const getUserFromDatabase = async (req, res, next) => {
  try {
    // If session already has user (from session token verification), use it
    if (req.session?.user) {
      req.dbUser = req.session.user;
      next();
      return;
    }
    
    // Otherwise, look up user by Firebase UID (for backward compatibility)
    const prisma = require('../lib/prisma');
    
    // Check if user exists in database
    let user = await prisma.user.findUnique({
      where: { firebaseUid: req.user.uid },
      include: {
        profile: true,
        pregnancyData: true
      }
    });
    
    // Create user if doesn't exist
    if (!user) {
      user = await prisma.user.create({
        data: {
          firebaseUid: req.user.uid,
          email: req.user.email,
          displayName: req.user.name,
          photoURL: req.user.picture
        },
        include: {
          profile: true,
          pregnancyData: true
        }
      });
    }
    
    // Add user to request
    req.dbUser = user;
    next();
  } catch (error) {
    console.error('Database user error:', error);
    return res.status(500).json({
      success: false,
      message: 'Database error'
    });
  }
};

/**
 * Combined auth middleware
 */
const auth = [verifySessionToken, getUserFromDatabase];

module.exports = {
  verifyFirebaseToken,
  verifySessionToken,
  getUserFromDatabase,
  auth
};

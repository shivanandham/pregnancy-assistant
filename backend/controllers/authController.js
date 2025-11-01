const prisma = require('../lib/prisma');
const SessionService = require('../services/sessionService');
const { verifyFirebaseToken } = require('../middleware/auth');

class AuthController {
  // Login with Firebase token, get session token
  static async login(req, res) {
    try {
      const { firebaseToken, deviceInfo } = req.body;
      
      if (!firebaseToken) {
        return res.status(400).json({
          success: false,
          message: 'Firebase token is required'
        });
      }
      
      // Verify Firebase token
      const firebaseVerification = await verifyFirebaseToken(firebaseToken);
      
      if (!firebaseVerification.success) {
        return res.status(401).json({
          success: false,
          message: firebaseVerification.error || 'Invalid Firebase token'
        });
      }
      
      const firebaseUser = firebaseVerification.user;
      
      // Get or create user in database
      let user = await prisma.user.findUnique({
        where: { firebaseUid: firebaseUser.uid },
        include: {
          profile: true,
          pregnancyData: true
        }
      });
      
      if (!user) {
        user = await prisma.user.create({
          data: {
            firebaseUid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.name,
            photoURL: firebaseUser.picture
          },
          include: {
            profile: true,
            pregnancyData: true
          }
        });
      } else {
        // Update user info from Firebase
        user = await prisma.user.update({
          where: { firebaseUid: firebaseUser.uid },
          data: {
            email: firebaseUser.email,
            displayName: firebaseUser.name,
            photoURL: firebaseUser.picture
          },
          include: {
            profile: true,
            pregnancyData: true
          }
        });
      }
      
      // Revoke all existing sessions for this user (only allow one active session)
      await SessionService.revokeAllUserSessions(user.id);
      
      // Generate new session token
      const sessionData = await SessionService.generateSessionToken(user.id, deviceInfo);
      
      res.json({
        success: true,
        data: {
          sessionToken: sessionData.sessionToken,
          refreshToken: sessionData.refreshToken,
          expiresAt: sessionData.expiresAt,
          refreshExpiresAt: sessionData.refreshExpiresAt,
          user: {
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoURL: user.photoURL,
            hasProfile: !!user.profile,
            hasPregnancyData: !!user.pregnancyData
          }
        }
      });
    } catch (error) {
      console.error('Error during login:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to login'
      });
    }
  }
  
  // Refresh session token
  static async refreshToken(req, res) {
    try {
      const { refreshToken } = req.body;
      
      if (!refreshToken) {
        return res.status(400).json({
          success: false,
          message: 'Refresh token is required'
        });
      }
      
      // Refresh session token
      const refreshResult = await SessionService.refreshSessionToken(refreshToken);
      
      if (!refreshResult.success) {
        return res.status(401).json({
          success: false,
          message: refreshResult.error || 'Invalid refresh token'
        });
      }
      
      res.json({
        success: true,
        data: {
          sessionToken: refreshResult.sessionToken,
          refreshToken: refreshResult.refreshToken,
          expiresAt: refreshResult.expiresAt,
          refreshExpiresAt: refreshResult.refreshExpiresAt
        }
      });
    } catch (error) {
      console.error('Error refreshing token:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to refresh token'
      });
    }
  }
  
  // Logout current session
  static async logout(req, res) {
    try {
      const sessionId = req.session?.id;
      
      if (!sessionId) {
        return res.status(400).json({
          success: false,
          message: 'No active session'
        });
      }
      
      // Revoke session
      const revokeResult = await SessionService.revokeSession(sessionId);
      
      if (!revokeResult.success) {
        return res.status(500).json({
          success: false,
          message: revokeResult.error || 'Failed to logout'
        });
      }
      
      res.json({
        success: true,
        message: 'Logged out successfully'
      });
    } catch (error) {
      console.error('Error during logout:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to logout'
      });
    }
  }
  
  // Logout all sessions
  static async logoutAll(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Revoke all user sessions
      const revokeResult = await SessionService.revokeAllUserSessions(userId);
      
      if (!revokeResult.success) {
        return res.status(500).json({
          success: false,
          message: revokeResult.error || 'Failed to logout all sessions'
        });
      }
      
      res.json({
        success: true,
        message: `Logged out from ${revokeResult.count} session(s)`
      });
    } catch (error) {
      console.error('Error during logout all:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to logout all sessions'
      });
    }
  }
  
  // Sync user data from Firebase to database
  static async syncUser(req, res) {
    try {
      const { uid, email, displayName, photoURL } = req.body;
      
      // Check if user exists
      let user = await prisma.user.findUnique({
        where: { firebaseUid: uid },
        include: {
          profile: true,
          pregnancyData: true
        }
      });
      
      if (user) {
        // Update existing user
        user = await prisma.user.update({
          where: { firebaseUid: uid },
          data: {
            email,
            displayName,
            photoURL
          },
          include: {
            profile: true,
            pregnancyData: true
          }
        });
      } else {
        // Create new user
        user = await prisma.user.create({
          data: {
            firebaseUid: uid,
            email,
            displayName,
            photoURL
          },
          include: {
            profile: true,
            pregnancyData: true
          }
        });
      }
      
      res.json({
        success: true,
        data: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          hasProfile: !!user.profile,
          hasPregnancyData: !!user.pregnancyData
        }
      });
    } catch (error) {
      console.error('Error syncing user:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to sync user'
      });
    }
  }
  
  // Get user profile
  static async getProfile(req, res) {
    try {
      const user = req.dbUser;
      
      res.json({
        success: true,
        data: {
          id: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          hasProfile: !!user.profile,
          hasPregnancyData: !!user.pregnancyData,
          profile: user.profile,
          pregnancyData: user.pregnancyData
        }
      });
    } catch (error) {
      console.error('Error getting user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get user profile'
      });
    }
  }
  
  // Delete user account
  static async deleteAccount(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Delete user (cascade will handle related data)
      await prisma.user.delete({
        where: { id: userId }
      });
      
      res.json({
        success: true,
        message: 'Account deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting account:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete account'
      });
    }
  }
}

module.exports = AuthController;

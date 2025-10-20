const prisma = require('../lib/prisma');

class AuthController {
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

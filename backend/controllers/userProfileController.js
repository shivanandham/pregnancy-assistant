const prisma = require('../lib/prisma');

class UserProfileController {
  // Get user profile
  static async getProfile(req, res) {
    try {
      const userId = req.dbUser.id;
      
      const profile = await prisma.userProfile.findUnique({
        where: { userId }
      });
      
      if (!profile) {
        return res.json({
          success: true,
          data: null,
          message: 'No profile found'
        });
      }

      res.json({
        success: true,
        data: profile
      });
    } catch (error) {
      console.error('Error getting user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create or update user profile
  static async saveProfile(req, res) {
    try {
      const userId = req.dbUser.id;
      const {
        height,
        weight,
        prePregnancyWeight,
        age,
        gender,
        locality,
        timezone,
        medicalHistory,
        allergies,
        medications,
        lifestyle
      } = req.body;

      // Validate required fields
      if (!height || !weight || !age) {
        return res.status(400).json({
          success: false,
          message: 'Height, weight, and age are required'
        });
      }

      // Check if profile exists
      const existingProfile = await prisma.userProfile.findUnique({
        where: { userId }
      });
      
      let profile;
      if (existingProfile) {
        // Update existing profile
        profile = await prisma.userProfile.update({
          where: { userId },
          data: {
            height,
            weight,
            prePregnancyWeight,
            age,
            gender,
            locality,
            timezone,
            medicalHistory,
            allergies,
            medications,
            lifestyle
          }
        });
      } else {
        // Create new profile
        profile = await prisma.userProfile.create({
          data: {
            userId,
            height,
            weight,
            prePregnancyWeight,
            age,
            gender,
            locality,
            timezone,
            medicalHistory,
            allergies,
            medications,
            lifestyle
          }
        });
      }

      res.json({
        success: true,
        data: profile,
        message: existingProfile ? 'Profile updated successfully' : 'Profile created successfully'
      });
    } catch (error) {
      console.error('Error saving user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Update specific profile fields
  static async updateProfile(req, res) {
    try {
      const userId = req.dbUser.id;
      const updates = req.body;
      
      if (Object.keys(updates).length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No updates provided'
        });
      }

      const profile = await prisma.userProfile.update({
        where: { userId },
        data: updates
      });

      res.json({
        success: true,
        data: profile,
        message: 'Profile updated successfully'
      });
    } catch (error) {
      console.error('Error updating user profile:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get profile context for AI
  static async getProfileContext(req, res) {
    try {
      const userId = req.dbUser.id;
      const profile = await prisma.userProfile.findUnique({
        where: { userId }
      });
      
      if (!profile) {
        return res.json({
          success: true,
          data: {
            hasProfile: false,
            context: 'No user profile available'
          }
        });
      }

      // Calculate BMI
      let bmi = null;
      if (profile.height && profile.weight) {
        const heightInMeters = profile.height / 100;
        bmi = profile.weight / (heightInMeters * heightInMeters);
      }

      // Calculate weight gain
      let weightGain = null;
      if (profile.prePregnancyWeight && profile.weight) {
        weightGain = profile.weight - profile.prePregnancyWeight;
      }

      const context = {
        hasProfile: true,
        basicInfo: `Age: ${profile.age} years, Height: ${profile.height} cm, Weight: ${profile.weight} kg`,
        medicalContext: `Medical history: ${JSON.stringify(profile.medicalHistory)}, Allergies: ${JSON.stringify(profile.allergies)}`,
        bmi: bmi,
        weightGain: weightGain
      };

      res.json({
        success: true,
        data: context
      });
    } catch (error) {
      console.error('Error getting profile context:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = UserProfileController;

const UserProfile = require('../models/UserProfile');

class UserProfileController {
  // Get user profile
  static async getProfile(req, res) {
    try {
      const profile = await UserProfile.get();
      
      if (!profile) {
        return res.json({
          success: true,
          data: null,
          message: 'No profile found'
        });
      }

      res.json({
        success: true,
        data: profile.toJSON()
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
      const existingProfile = await UserProfile.get();
      
      let profile;
      if (existingProfile) {
        // Update existing profile
        profile = await UserProfile.update({
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
        });
      } else {
        // Create new profile
        profile = new UserProfile({
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
        });
        await profile.save();
      }

      res.json({
        success: true,
        data: profile.toJSON(),
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
      const updates = req.body;
      
      if (Object.keys(updates).length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No updates provided'
        });
      }

      const profile = await UserProfile.update(updates);

      res.json({
        success: true,
        data: profile.toJSON(),
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
      const profile = await UserProfile.get();
      
      if (!profile) {
        return res.json({
          success: true,
          data: {
            hasProfile: false,
            context: 'No user profile available'
          }
        });
      }

      const context = {
        hasProfile: true,
        basicInfo: profile.getFormattedProfile(),
        medicalContext: profile.getMedicalContext(),
        bmi: profile.getBMI(),
        weightGain: profile.getWeightGain()
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

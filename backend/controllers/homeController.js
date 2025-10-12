const PregnancyTip = require('../models/PregnancyTip');
const PregnancyMilestone = require('../models/PregnancyMilestone');
const DailyChecklist = require('../models/DailyChecklist');
const Pregnancy = require('../models/Pregnancy');
const ChecklistCompletion = require('../models/ChecklistCompletion');
const UserProfile = require('../models/UserProfile');

class HomeController {
  // Get all home screen data
  static async getHomeData(req, res) {
    try {
      // Get current pregnancy data to determine the week
      const pregnancy = await Pregnancy.getCurrent();
      
      if (!pregnancy) {
        return res.json({
          success: true,
          data: {
            hasPregnancyData: false,
            message: 'No pregnancy data found. Please set up your pregnancy information.'
          }
        });
      }

      const currentWeek = pregnancy.getCurrentWeek();
      
      // Get tips for current week
      const tips = await PregnancyTip.getTipsForWeek(currentWeek);
      
      // Get milestones for current week
      const currentMilestones = PregnancyMilestone.getMilestonesForWeek(currentWeek);
      const upcomingMilestones = PregnancyMilestone.getUpcomingMilestones(currentWeek, 2);
      
      // Get user profile for personalized checklist
      const userProfile = await UserProfile.get();
      
      // Generate dynamic daily checklist
      const checklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile);
      const checklistByCategory = HomeController._groupChecklistByCategory(checklist);
      
      res.json({
        success: true,
        data: {
          hasPregnancyData: true,
          currentWeek: currentWeek,
          pregnancy: pregnancy.toJSON(),
          tips: tips.map(tip => tip.toJSON()),
          currentMilestones: currentMilestones.map(milestone => milestone.toJSON()),
          upcomingMilestones: upcomingMilestones.map(milestone => milestone.toJSON()),
          checklist: checklist.map(task => task.toJSON()),
          checklistByCategory: Object.keys(checklistByCategory).reduce((acc, category) => {
            acc[category] = checklistByCategory[category].map(task => task.toJSON());
            return acc;
          }, {})
        }
      });
    } catch (error) {
      console.error('Error getting home data:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get tips for a specific week
  static async getTipsForWeek(req, res) {
    try {
      const { week } = req.params;
      const weekNum = parseInt(week);
      
      if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week number. Must be between 1 and 42.'
        });
      }

      const tips = await PregnancyTip.getTipsForWeek(weekNum);
      
      res.json({
        success: true,
        data: tips.map(tip => tip.toJSON())
      });
    } catch (error) {
      console.error('Error getting tips for week:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get milestones for a specific week
  static async getMilestonesForWeek(req, res) {
    try {
      const { week } = req.params;
      const weekNum = parseInt(week);
      
      if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week number. Must be between 1 and 42.'
        });
      }

      const currentMilestones = PregnancyMilestone.getMilestonesForWeek(weekNum);
      const upcomingMilestones = PregnancyMilestone.getUpcomingMilestones(weekNum, 3);
      const recentMilestones = PregnancyMilestone.getRecentMilestones(weekNum, 3);
      
      res.json({
        success: true,
        data: {
          current: currentMilestones.map(milestone => milestone.toJSON()),
          upcoming: upcomingMilestones.map(milestone => milestone.toJSON()),
          recent: recentMilestones.map(milestone => milestone.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting milestones for week:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get daily checklist for a specific week
  static async getChecklistForWeek(req, res) {
    try {
      const { week } = req.params;
      const weekNum = parseInt(week);
      
      if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week number. Must be between 1 and 42.'
        });
      }

      const checklist = DailyChecklist.getChecklistForWeek(weekNum);
      const checklistByCategory = DailyChecklist.getTasksByCategory(weekNum);
      
      res.json({
        success: true,
        data: {
          tasks: checklist.map(task => task.toJSON()),
          byCategory: Object.keys(checklistByCategory).reduce((acc, category) => {
            acc[category] = checklistByCategory[category].map(task => task.toJSON());
            return acc;
          }, {})
        }
      });
    } catch (error) {
      console.error('Error getting checklist for week:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Clear expired tips (maintenance endpoint)
  static async clearExpiredTips(req, res) {
    try {
      await PregnancyTip.clearExpiredTips();
      
      res.json({
        success: true,
        message: 'Expired tips cleared successfully'
      });
    } catch (error) {
      console.error('Error clearing expired tips:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Toggle checklist item completion
  static async toggleChecklistCompletion(req, res) {
    try {
      const { checklistItemId } = req.params;
      const { date } = req.body;
      
      if (!checklistItemId) {
        return res.status(400).json({
          success: false,
          message: 'Checklist item ID is required'
        });
      }

      const completionDate = date ? new Date(date) : new Date();
      completionDate.setHours(0, 0, 0, 0); // Set to start of day

      // Check if already completed
      const isCompleted = await ChecklistCompletion.isCompleted(checklistItemId, completionDate);
      
      if (isCompleted) {
        // Remove completion
        const completion = new ChecklistCompletion({
          checklistItemId,
          date: completionDate,
          completedAt: new Date()
        });
        await completion.delete();
        
        res.json({
          success: true,
          data: {
            completed: false,
            message: 'Checklist item marked as incomplete'
          }
        });
      } else {
        // Add completion
        const completion = new ChecklistCompletion({
          checklistItemId,
          date: completionDate,
          completedAt: new Date()
        });
        const savedCompletion = await completion.save();
        
        res.json({
          success: true,
          data: {
            completed: true,
            completion: savedCompletion.toJSON(),
            message: 'Checklist item marked as complete'
          }
        });
      }
    } catch (error) {
      console.error('Error toggling checklist completion:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get checklist completions for a specific date
  static async getChecklistCompletions(req, res) {
    try {
      const { date } = req.params;
      
      if (!date) {
        return res.status(400).json({
          success: false,
          message: 'Date is required'
        });
      }

      const completionDate = new Date(date);
      completionDate.setHours(0, 0, 0, 0); // Set to start of day

      const completions = await ChecklistCompletion.getCompletionsForDate(completionDate);
      
      res.json({
        success: true,
        data: {
          date: completionDate,
          completions: completions.map(completion => completion.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting checklist completions:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Generate dynamic checklist for a specific date
  static async generateDynamicChecklist(req, res) {
    try {
      const { date } = req.query;
      const targetDate = date ? new Date(date) : new Date();
      
      // Get current pregnancy data
      const pregnancy = await Pregnancy.getCurrent();
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found. Please set up your pregnancy information.'
        });
      }

      // Get user profile for personalization
      const userProfile = await UserProfile.get();
      
      // Generate dynamic checklist
      const checklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile, targetDate);
      const checklistByCategory = HomeController._groupChecklistByCategory(checklist);
      
      res.json({
        success: true,
        data: {
          date: targetDate,
          tasks: checklist.map(task => task.toJSON()),
          byCategory: checklistByCategory
        }
      });
    } catch (error) {
      console.error('Error generating dynamic checklist:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper method to group checklist by category
  static _groupChecklistByCategory(checklist) {
    const categories = {};
    
    checklist.forEach(task => {
      if (!categories[task.category]) {
        categories[task.category] = [];
      }
      categories[task.category].push(task);
    });
    
    return categories;
  }
}

module.exports = HomeController;

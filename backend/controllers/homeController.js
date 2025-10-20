const prisma = require('../lib/prisma');
const PregnancyTip = require('../models/PregnancyTip');
const PregnancyMilestone = require('../models/PregnancyMilestone');
const DailyChecklist = require('../models/DailyChecklist');

class HomeController {
  // Calculate current pregnancy week
  static calculateCurrentWeek(lastMenstrualPeriod) {
    if (!lastMenstrualPeriod) return null;
    
    const lmp = new Date(lastMenstrualPeriod);
    const today = new Date();
    const diffTime = today - lmp;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    const currentWeek = Math.floor(diffDays / 7);
    
    return Math.max(0, currentWeek);
  }

  // Get all home screen data
  static async getHomeData(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Get current pregnancy data to determine the week
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId }
      });
      
      if (!pregnancy) {
        return res.json({
          success: true,
          data: {
            hasPregnancyData: false,
            message: 'No pregnancy data found. Please set up your pregnancy information.'
          }
        });
      }

      const currentWeek = HomeController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      
      // Get tips for current week from database
      const tips = await prisma.pregnancyTip.findMany({
        where: {
          week: currentWeek
        }
      });
      
      // Get milestones for current week (using static data)
      const currentMilestones = PregnancyMilestone.getMilestonesForWeek(currentWeek);
      const upcomingMilestones = PregnancyMilestone.getUpcomingMilestones(currentWeek, 2);
      
      // Get user profile for personalized checklist
      const userProfile = await prisma.userProfile.findUnique({
        where: { userId: req.dbUser.id }
      });
      
      // Generate dynamic daily checklist
      const checklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile, new Date());
      const checklistByCategory = HomeController._groupChecklistByCategory(checklist);
      
      res.json({
        success: true,
        data: {
          hasPregnancyData: true,
          currentWeek: currentWeek,
          pregnancy: pregnancy,
          tips: tips,
          currentMilestones: currentMilestones,
          upcomingMilestones: upcomingMilestones,
          checklist: checklist,
          checklistByCategory: checklistByCategory
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

      const tips = await prisma.pregnancyTip.findMany({
        where: {
          week: weekNum
        }
      });
      
      res.json({
        success: true,
        data: tips
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
      const now = new Date();
      await prisma.pregnancyTip.deleteMany({
        where: {
          expiresAt: {
            lt: now
          }
        }
      });
      
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
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId: req.dbUser.id }
      });
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found. Please set up your pregnancy information.'
        });
      }

      // Get user profile for personalization
      const userProfile = await prisma.userProfile.findUnique({
        where: { userId: req.dbUser.id }
      });
      
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

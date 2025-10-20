const prisma = require('../lib/prisma');
const DailyChecklist = require('../models/DailyChecklist');
const ChecklistCompletion = require('../models/ChecklistCompletion');

class ChecklistController {
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
          week: weekNum,
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
      const checklistByCategory = ChecklistController._groupChecklistByCategory(checklist);
      
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

  // Get current week dynamic checklist
  static async getCurrentWeekChecklist(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Get current pregnancy data
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId }
      });
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found. Please set up your pregnancy information.'
        });
      }

      // Get user profile for personalization
      const userProfile = await prisma.userProfile.findUnique({
        where: { userId }
      });
      
      // Generate dynamic checklist for today
      const checklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile, new Date());
      const checklistByCategory = ChecklistController._groupChecklistByCategory(checklist);
      
      res.json({
        success: true,
        data: {
          date: new Date(),
          tasks: checklist.map(task => task.toJSON()),
          byCategory: checklistByCategory
        }
      });
    } catch (error) {
      console.error('Error getting current week checklist:', error);
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

  // Get checklist completions for a date range
  static async getChecklistCompletionsForRange(req, res) {
    try {
      const { startDate, endDate } = req.query;
      
      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          message: 'Start date and end date are required'
        });
      }

      const start = new Date(startDate);
      const end = new Date(endDate);
      start.setHours(0, 0, 0, 0);
      end.setHours(23, 59, 59, 999);

      const completions = await ChecklistCompletion.getCompletionsForDateRange(start, end);
      
      res.json({
        success: true,
        data: {
          dateRange: { start, end },
          completions: completions.map(completion => completion.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting checklist completions for range:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get checklist statistics
  static async getChecklistStats(req, res) {
    try {
      const { days = 7 } = req.query;
      const daysBack = parseInt(days);
      
      if (isNaN(daysBack) || daysBack < 1 || daysBack > 365) {
        return res.status(400).json({
          success: false,
          message: 'Invalid days parameter. Must be between 1 and 365.'
        });
      }

      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - daysBack);
      startDate.setHours(0, 0, 0, 0);
      endDate.setHours(23, 59, 59, 999);

      const completions = await ChecklistCompletion.getCompletionsForDateRange(startDate, endDate);
      
      // Calculate statistics
      const totalDays = daysBack;
      const completedDays = new Set(completions.map(c => c.date.toDateString())).size;
      const completionRate = totalDays > 0 ? (completedDays / totalDays) * 100 : 0;
      
      // Group by category
      const categoryStats = {};
      completions.forEach(completion => {
        if (!categoryStats[completion.category]) {
          categoryStats[completion.category] = 0;
        }
        categoryStats[completion.category]++;
      });
      
      res.json({
        success: true,
        data: {
          period: { start: startDate, end: endDate, days: totalDays },
          stats: {
            totalDays,
            completedDays,
            completionRate: Math.round(completionRate * 100) / 100,
            categoryStats
          }
        }
      });
    } catch (error) {
      console.error('Error getting checklist stats:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get checklist items by category
  static async getChecklistByCategory(req, res) {
    try {
      const { category } = req.params;
      const { week } = req.query;
      
      let checklist;
      if (week) {
        const weekNum = parseInt(week);
        if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
          return res.status(400).json({
            success: false,
            message: 'Invalid week number. Must be between 1 and 42.'
          });
        }
        checklist = DailyChecklist.getChecklistForWeek(weekNum);
      } else {
        // Get current week checklist
        const userId = req.dbUser.id;
        const pregnancy = await prisma.pregnancyData.findUnique({
          where: { userId }
        });
        if (!pregnancy) {
          return res.status(404).json({
            success: false,
            message: 'No pregnancy data found. Please set up your pregnancy information.'
          });
        }
        
        const userProfile = await prisma.userProfile.findUnique({
          where: { userId }
        });
        
        checklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile, new Date());
      }
      
      const categoryItems = checklist.filter(task => task.category === category);
      
      res.json({
        success: true,
        data: {
          category,
          tasks: categoryItems.map(task => task.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting checklist by category:', error);
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

module.exports = ChecklistController;

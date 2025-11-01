const prisma = require('../lib/prisma');
const PregnancyTip = require('../models/PregnancyTip');

class TipsController {
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
        },
        orderBy: {
          createdAt: 'desc'
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

  // Get all tips for current pregnancy week
  static async getCurrentWeekTips(req, res) {
    try {
      const userId = req.dbUser.id;
      
      // Get current pregnancy data to determine the week
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId }
      });
      
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found. Please set up your pregnancy information.'
        });
      }

      const currentWeek = TipsController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      
      // Use the model method which generates tips if they don't exist
      const tips = await PregnancyTip.getTipsForWeek(currentWeek);
      
      res.json({
        success: true,
        data: {
          currentWeek: currentWeek,
          tips: tips.map(tip => tip.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting current week tips:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get tips for a range of weeks
  static async getTipsForWeekRange(req, res) {
    try {
      const { startWeek, endWeek } = req.query;
      const start = parseInt(startWeek);
      const end = parseInt(endWeek);
      
      if (isNaN(start) || isNaN(end) || start < 1 || end > 42 || start > end) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week range. Start and end weeks must be between 1 and 42, with start <= end.'
        });
      }

      const tips = await prisma.pregnancyTip.findMany({
        where: {
          week: {
            gte: start,
            lte: end
          }
        },
        orderBy: [
          { week: 'asc' },
          { createdAt: 'desc' }
        ]
      });
      
      res.json({
        success: true,
        data: {
          weekRange: { start, end },
          tips: tips
        }
      });
    } catch (error) {
      console.error('Error getting tips for week range:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create a new tip (admin/maintenance endpoint)
  static async createTip(req, res) {
    try {
      const { week, title, content, category, expiresAt } = req.body;
      
      if (!week || !title || !content) {
        return res.status(400).json({
          success: false,
          message: 'Week, title, and content are required'
        });
      }

      const weekNum = parseInt(week);
      if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
        return res.status(400).json({
          success: false,
          message: 'Invalid week number. Must be between 1 and 42.'
        });
      }

      const tip = await prisma.pregnancyTip.create({
        data: {
          week: weekNum,
          title,
          content,
          category: category || 'general',
          expiresAt: expiresAt ? new Date(expiresAt) : null
        }
      });
      
      res.status(201).json({
        success: true,
        data: tip
      });
    } catch (error) {
      console.error('Error creating tip:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Update a tip (admin/maintenance endpoint)
  static async updateTip(req, res) {
    try {
      const { id } = req.params;
      const { week, title, content, category, expiresAt } = req.body;
      
      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'Tip ID is required'
        });
      }

      const updateData = {};
      if (week !== undefined) {
        const weekNum = parseInt(week);
        if (isNaN(weekNum) || weekNum < 1 || weekNum > 42) {
          return res.status(400).json({
            success: false,
            message: 'Invalid week number. Must be between 1 and 42.'
          });
        }
        updateData.week = weekNum;
      }
      if (title !== undefined) updateData.title = title;
      if (content !== undefined) updateData.content = content;
      if (category !== undefined) updateData.category = category;
      if (expiresAt !== undefined) updateData.expiresAt = expiresAt ? new Date(expiresAt) : null;

      const tip = await prisma.pregnancyTip.update({
        where: { id: parseInt(id) },
        data: updateData
      });
      
      res.json({
        success: true,
        data: tip
      });
    } catch (error) {
      console.error('Error updating tip:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete a tip (admin/maintenance endpoint)
  static async deleteTip(req, res) {
    try {
      const { id } = req.params;
      
      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'Tip ID is required'
        });
      }

      await prisma.pregnancyTip.delete({
        where: { id: parseInt(id) }
      });
      
      res.json({
        success: true,
        message: 'Tip deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting tip:', error);
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
      const deletedCount = await prisma.pregnancyTip.deleteMany({
        where: {
          expiresAt: {
            lt: now
          }
        }
      });
      
      res.json({
        success: true,
        message: `Cleared ${deletedCount.count} expired tips`,
        deletedCount: deletedCount.count
      });
    } catch (error) {
      console.error('Error clearing expired tips:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get tips by category
  static async getTipsByCategory(req, res) {
    try {
      const { category } = req.params;
      const { week } = req.query;
      
      const whereClause = { category };
      if (week) {
        const weekNum = parseInt(week);
        if (!isNaN(weekNum) && weekNum >= 1 && weekNum <= 42) {
          whereClause.week = weekNum;
        }
      }

      const tips = await prisma.pregnancyTip.findMany({
        where: whereClause,
        orderBy: [
          { week: 'asc' },
          { createdAt: 'desc' }
        ]
      });
      
      res.json({
        success: true,
        data: {
          category,
          tips: tips
        }
      });
    } catch (error) {
      console.error('Error getting tips by category:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Helper method to calculate current pregnancy week
  static calculateCurrentWeek(lastMenstrualPeriod) {
    if (!lastMenstrualPeriod) return null;
    
    const lmp = new Date(lastMenstrualPeriod);
    const today = new Date();
    const diffTime = today - lmp;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    const currentWeek = Math.floor(diffDays / 7);
    
    return Math.max(0, currentWeek);
  }
}

module.exports = TipsController;

const prisma = require('../lib/prisma');
const PregnancyMilestone = require('../models/PregnancyMilestone');

class MilestonesController {
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
          currentWeek: weekNum,
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

  // Get current week milestones
  static async getCurrentWeekMilestones(req, res) {
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

      const currentWeek = MilestonesController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      const currentMilestones = PregnancyMilestone.getMilestonesForWeek(currentWeek);
      const upcomingMilestones = PregnancyMilestone.getUpcomingMilestones(currentWeek, 2);
      
      res.json({
        success: true,
        data: {
          currentWeek: currentWeek,
          current: currentMilestones.map(milestone => milestone.toJSON()),
          upcoming: upcomingMilestones.map(milestone => milestone.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting current week milestones:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get milestones for a range of weeks
  static async getMilestonesForWeekRange(req, res) {
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

      const milestones = [];
      for (let week = start; week <= end; week++) {
        const weekMilestones = PregnancyMilestone.getMilestonesForWeek(week);
        milestones.push({
          week: week,
          milestones: weekMilestones.map(milestone => milestone.toJSON())
        });
      }
      
      res.json({
        success: true,
        data: {
          weekRange: { start, end },
          milestones: milestones
        }
      });
    } catch (error) {
      console.error('Error getting milestones for week range:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get upcoming milestones
  static async getUpcomingMilestones(req, res) {
    try {
      const { week } = req.query;
      const { count = 5 } = req.query;
      
      let currentWeek;
      if (week) {
        currentWeek = parseInt(week);
        if (isNaN(currentWeek) || currentWeek < 1 || currentWeek > 42) {
          return res.status(400).json({
            success: false,
            message: 'Invalid week number. Must be between 1 and 42.'
          });
        }
      } else {
        // Get current pregnancy week
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
        
        currentWeek = MilestonesController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      }

      const upcomingMilestones = PregnancyMilestone.getUpcomingMilestones(currentWeek, parseInt(count));
      
      res.json({
        success: true,
        data: {
          currentWeek: currentWeek,
          upcoming: upcomingMilestones.map(milestone => milestone.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting upcoming milestones:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get recent milestones
  static async getRecentMilestones(req, res) {
    try {
      const { week } = req.query;
      const { count = 5 } = req.query;
      
      let currentWeek;
      if (week) {
        currentWeek = parseInt(week);
        if (isNaN(currentWeek) || currentWeek < 1 || currentWeek > 42) {
          return res.status(400).json({
            success: false,
            message: 'Invalid week number. Must be between 1 and 42.'
          });
        }
      } else {
        // Get current pregnancy week
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
        
        currentWeek = MilestonesController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      }

      const recentMilestones = PregnancyMilestone.getRecentMilestones(currentWeek, parseInt(count));
      
      res.json({
        success: true,
        data: {
          currentWeek: currentWeek,
          recent: recentMilestones.map(milestone => milestone.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting recent milestones:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get milestones by trimester
  static async getMilestonesByTrimester(req, res) {
    try {
      const { trimester } = req.params;
      const trimesterNum = parseInt(trimester);
      
      if (isNaN(trimesterNum) || trimesterNum < 1 || trimesterNum > 3) {
        return res.status(400).json({
          success: false,
          message: 'Invalid trimester number. Must be between 1 and 3.'
        });
      }

      let startWeek, endWeek;
      switch (trimesterNum) {
        case 1:
          startWeek = 1;
          endWeek = 12;
          break;
        case 2:
          startWeek = 13;
          endWeek = 26;
          break;
        case 3:
          startWeek = 27;
          endWeek = 40;
          break;
      }

      const milestones = [];
      for (let week = startWeek; week <= endWeek; week++) {
        const weekMilestones = PregnancyMilestone.getMilestonesForWeek(week);
        if (weekMilestones.length > 0) {
          milestones.push({
            week: week,
            milestones: weekMilestones.map(milestone => milestone.toJSON())
          });
        }
      }
      
      res.json({
        success: true,
        data: {
          trimester: trimesterNum,
          weekRange: { start: startWeek, end: endWeek },
          milestones: milestones
        }
      });
    } catch (error) {
      console.error('Error getting milestones by trimester:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get all available milestones
  static async getAllMilestones(req, res) {
    try {
      const allMilestones = PregnancyMilestone.getAllMilestones();
      
      res.json({
        success: true,
        data: {
          milestones: allMilestones.map(milestone => milestone.toJSON())
        }
      });
    } catch (error) {
      console.error('Error getting all milestones:', error);
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

module.exports = MilestonesController;

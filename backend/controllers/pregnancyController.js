const Pregnancy = require('../models/Pregnancy');

class PregnancyController {
  // Get current pregnancy data
  static async getCurrent(req, res) {
    try {
      const pregnancy = await Pregnancy.getCurrent();
      
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found'
        });
      }
      
      res.json({
        success: true,
        data: pregnancy.toJSON()
      });
    } catch (error) {
      console.error('Error getting pregnancy data:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create or update pregnancy data
  static async createOrUpdate(req, res) {
    try {
      const { dueDate, lastMenstrualPeriod, notes } = req.body;
      
      // Validation
      if (!dueDate || !lastMenstrualPeriod) {
        return res.status(400).json({
          success: false,
          message: 'Due date and last menstrual period are required'
        });
      }

      // Validate dates
      const dueDateObj = new Date(dueDate);
      const lmpObj = new Date(lastMenstrualPeriod);
      
      if (isNaN(dueDateObj.getTime()) || isNaN(lmpObj.getTime())) {
        return res.status(400).json({
          success: false,
          message: 'Invalid date format'
        });
      }

      if (lmpObj >= dueDateObj) {
        return res.status(400).json({
          success: false,
          message: 'Last menstrual period must be before due date'
        });
      }

      // Check if pregnancy data already exists
      const existingPregnancy = await Pregnancy.getCurrent();
      
      let pregnancy;
      if (existingPregnancy) {
        // Update existing
        pregnancy = new Pregnancy({
          id: existingPregnancy.id,
          dueDate,
          lastMenstrualPeriod,
          notes,
          createdAt: existingPregnancy.createdAt,
          updatedAt: new Date().toISOString()
        });
      } else {
        // Create new
        pregnancy = new Pregnancy({
          dueDate,
          lastMenstrualPeriod,
          notes
        });
      }

      await pregnancy.save();
      
      res.json({
        success: true,
        data: pregnancy.toJSON(),
        message: existingPregnancy ? 'Pregnancy data updated' : 'Pregnancy data created'
      });
    } catch (error) {
      console.error('Error saving pregnancy data:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete pregnancy data
  static async delete(req, res) {
    try {
      const pregnancy = await Pregnancy.getCurrent();
      
      if (!pregnancy) {
        return res.status(404).json({
          success: false,
          message: 'No pregnancy data found'
        });
      }

      await Pregnancy.delete(pregnancy.id);
      
      res.json({
        success: true,
        message: 'Pregnancy data deleted'
      });
    } catch (error) {
      console.error('Error deleting pregnancy data:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = PregnancyController;

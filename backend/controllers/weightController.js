const WeightEntry = require('../models/WeightEntry');

class WeightController {
  // Get all weight entries
  static async getAll(req, res) {
    try {
      const weightEntries = await WeightEntry.getAll();
      
      res.json({
        success: true,
        data: weightEntries.map(entry => entry.toJSON())
      });
    } catch (error) {
      console.error('Error getting weight entries:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get weight entries by date range
  static async getByDateRange(req, res) {
    try {
      const { startDate, endDate } = req.query;
      
      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          message: 'Start date and end date are required'
        });
      }

      const weightEntries = await WeightEntry.getByDateRange(startDate, endDate);
      
      res.json({
        success: true,
        data: weightEntries.map(entry => entry.toJSON())
      });
    } catch (error) {
      console.error('Error getting weight entries by date range:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get weight entry by ID
  static async getById(req, res) {
    try {
      const { id } = req.params;
      const weightEntry = await WeightEntry.getById(id);
      
      if (!weightEntry) {
        return res.status(404).json({
          success: false,
          message: 'Weight entry not found'
        });
      }
      
      res.json({
        success: true,
        data: weightEntry.toJSON()
      });
    } catch (error) {
      console.error('Error getting weight entry:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create new weight entry
  static async create(req, res) {
    try {
      const { weight, dateTime, notes } = req.body;
      
      // Validation
      if (!weight || !dateTime) {
        return res.status(400).json({
          success: false,
          message: 'Weight and date/time are required'
        });
      }

      // Validate weight
      const weightNum = parseFloat(weight);
      if (isNaN(weightNum) || weightNum <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Weight must be a positive number'
        });
      }

      // Validate date
      const dateObj = new Date(dateTime);
      if (isNaN(dateObj.getTime())) {
        return res.status(400).json({
          success: false,
          message: 'Invalid date format'
        });
      }

      const weightEntry = new WeightEntry({
        weight: weightNum,
        dateTime,
        notes
      });

      await weightEntry.save();
      
      res.status(201).json({
        success: true,
        data: weightEntry.toJSON(),
        message: 'Weight entry created successfully'
      });
    } catch (error) {
      console.error('Error creating weight entry:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete weight entry
  static async delete(req, res) {
    try {
      const { id } = req.params;
      const weightEntry = await WeightEntry.getById(id);
      
      if (!weightEntry) {
        return res.status(404).json({
          success: false,
          message: 'Weight entry not found'
        });
      }

      await WeightEntry.delete(id);
      
      res.json({
        success: true,
        message: 'Weight entry deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting weight entry:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = WeightController;

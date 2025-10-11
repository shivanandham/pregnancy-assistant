const Symptom = require('../models/Symptom');

class SymptomController {
  // Get all symptoms
  static async getAll(req, res) {
    try {
      const symptoms = await Symptom.getAll();
      
      res.json({
        success: true,
        data: symptoms.map(symptom => symptom.toJSON())
      });
    } catch (error) {
      console.error('Error getting symptoms:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get symptoms by date range
  static async getByDateRange(req, res) {
    try {
      const { startDate, endDate } = req.query;
      
      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          message: 'Start date and end date are required'
        });
      }

      const symptoms = await Symptom.getByDateRange(startDate, endDate);
      
      res.json({
        success: true,
        data: symptoms.map(symptom => symptom.toJSON())
      });
    } catch (error) {
      console.error('Error getting symptoms by date range:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get symptom by ID
  static async getById(req, res) {
    try {
      const { id } = req.params;
      const symptom = await Symptom.getById(id);
      
      if (!symptom) {
        return res.status(404).json({
          success: false,
          message: 'Symptom not found'
        });
      }
      
      res.json({
        success: true,
        data: symptom.toJSON()
      });
    } catch (error) {
      console.error('Error getting symptom:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create new symptom
  static async create(req, res) {
    try {
      const { type, severity, dateTime, notes, customType } = req.body;
      
      // Validation
      if (!type || !severity || !dateTime) {
        return res.status(400).json({
          success: false,
          message: 'Type, severity, and date/time are required'
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

      const symptom = new Symptom({
        type,
        severity,
        dateTime,
        notes,
        customType
      });

      await symptom.save();
      
      res.status(201).json({
        success: true,
        data: symptom.toJSON(),
        message: 'Symptom created successfully'
      });
    } catch (error) {
      console.error('Error creating symptom:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete symptom
  static async delete(req, res) {
    try {
      const { id } = req.params;
      const symptom = await Symptom.getById(id);
      
      if (!symptom) {
        return res.status(404).json({
          success: false,
          message: 'Symptom not found'
        });
      }

      await Symptom.delete(id);
      
      res.json({
        success: true,
        message: 'Symptom deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting symptom:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = SymptomController;

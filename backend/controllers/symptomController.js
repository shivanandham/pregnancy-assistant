const prisma = require('../lib/prisma');

class SymptomController {
  // Get all symptoms
  static async getAll(req, res) {
    try {
      const userId = req.dbUser.id;
      const symptoms = await prisma.symptom.findMany({
        where: { userId },
        orderBy: { dateTime: 'desc' }
      });
      
      res.json({
        success: true,
        data: symptoms
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
      const userId = req.dbUser.id;
      const { startDate, endDate } = req.query;
      
      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          message: 'Start date and end date are required'
        });
      }

      const symptoms = await prisma.symptom.findMany({
        where: {
          userId,
          dateTime: {
            gte: new Date(startDate),
            lte: new Date(endDate)
          }
        },
        orderBy: { dateTime: 'desc' }
      });
      
      res.json({
        success: true,
        data: symptoms
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      const symptom = await prisma.symptom.findFirst({
        where: { 
          id,
          userId 
        }
      });
      
      if (!symptom) {
        return res.status(404).json({
          success: false,
          message: 'Symptom not found'
        });
      }
      
      res.json({
        success: true,
        data: symptom
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
      const userId = req.dbUser.id;
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

      const savedSymptom = await prisma.symptom.create({
        data: {
          userId,
          type,
          severity,
          dateTime: dateObj,
          notes,
          customType
        }
      });
      
      res.status(201).json({
        success: true,
        data: savedSymptom,
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
      const userId = req.dbUser.id;
      const { id } = req.params;
      const symptom = await prisma.symptom.findFirst({
        where: { 
          id,
          userId 
        }
      });
      
      if (!symptom) {
        return res.status(404).json({
          success: false,
          message: 'Symptom not found'
        });
      }

      await prisma.symptom.delete({
        where: { id }
      });
      
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

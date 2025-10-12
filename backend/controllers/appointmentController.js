const Appointment = require('../models/Appointment');

class AppointmentController {
  // Get all appointments
  static async getAll(req, res) {
    try {
      const appointments = await Appointment.getAll();
      
      res.json({
        success: true,
        data: appointments.map(appointment => appointment.toJSON())
      });
    } catch (error) {
      console.error('Error getting appointments:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get upcoming appointments
  static async getUpcoming(req, res) {
    try {
      const appointments = await Appointment.getUpcoming();
      
      res.json({
        success: true,
        data: appointments.map(appointment => appointment.toJSON())
      });
    } catch (error) {
      console.error('Error getting upcoming appointments:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get appointment by ID
  static async getById(req, res) {
    try {
      const { id } = req.params;
      const appointment = await Appointment.getById(id);
      
      if (!appointment) {
        return res.status(404).json({
          success: false,
          message: 'Appointment not found'
        });
      }
      
      res.json({
        success: true,
        data: appointment.toJSON()
      });
    } catch (error) {
      console.error('Error getting appointment:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Create new appointment
  static async create(req, res) {
    try {
      const { title, type, dateTime, location, doctor, notes } = req.body;
      
      // Validation
      if (!title || !type || !dateTime) {
        return res.status(400).json({
          success: false,
          message: 'Title, type, and date/time are required'
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

      const appointment = new Appointment({
        title,
        type,
        dateTime,
        location,
        doctor,
        notes
      });

      const savedAppointment = await appointment.save();
      
      res.status(201).json({
        success: true,
        data: savedAppointment.toJSON(),
        message: 'Appointment created successfully'
      });
    } catch (error) {
      console.error('Error creating appointment:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Update appointment
  static async update(req, res) {
    try {
      const { id } = req.params;
      const { title, type, dateTime, location, doctor, notes, isCompleted } = req.body;
      
      const existingAppointment = await Appointment.getById(id);
      
      if (!existingAppointment) {
        return res.status(404).json({
          success: false,
          message: 'Appointment not found'
        });
      }

      // Validate date if provided
      if (dateTime) {
        const dateObj = new Date(dateTime);
        if (isNaN(dateObj.getTime())) {
          return res.status(400).json({
            success: false,
            message: 'Invalid date format'
          });
        }
      }

      const appointment = new Appointment({
        id: existingAppointment.id,
        title: title || existingAppointment.title,
        type: type || existingAppointment.type,
        dateTime: dateTime || existingAppointment.dateTime,
        location: location !== undefined ? location : existingAppointment.location,
        doctor: doctor !== undefined ? doctor : existingAppointment.doctor,
        notes: notes !== undefined ? notes : existingAppointment.notes,
        isCompleted: isCompleted !== undefined ? isCompleted : existingAppointment.isCompleted,
        createdAt: existingAppointment.createdAt,
        updatedAt: new Date().toISOString()
      });

      const savedAppointment = await appointment.save();
      
      res.json({
        success: true,
        data: savedAppointment.toJSON(),
        message: 'Appointment updated successfully'
      });
    } catch (error) {
      console.error('Error updating appointment:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete appointment
  static async delete(req, res) {
    try {
      const { id } = req.params;
      const appointment = await Appointment.getById(id);
      
      if (!appointment) {
        return res.status(404).json({
          success: false,
          message: 'Appointment not found'
        });
      }

      await Appointment.delete(id);
      
      res.json({
        success: true,
        message: 'Appointment deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting appointment:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = AppointmentController;

const express = require('express');
const router = express.Router();
const AppointmentController = require('../controllers/appointmentController');

// GET /api/appointments - Get all appointments
router.get('/', AppointmentController.getAll);

// GET /api/appointments/upcoming - Get upcoming appointments
router.get('/upcoming', AppointmentController.getUpcoming);

// GET /api/appointments/:id - Get appointment by ID
router.get('/:id', AppointmentController.getById);

// POST /api/appointments - Create new appointment
router.post('/', AppointmentController.create);

// PUT /api/appointments/:id - Update appointment
router.put('/:id', AppointmentController.update);

// DELETE /api/appointments/:id - Delete appointment
router.delete('/:id', AppointmentController.delete);

module.exports = router;

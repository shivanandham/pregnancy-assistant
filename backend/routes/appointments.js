const express = require('express');
const router = express.Router();
const AppointmentController = require('../controllers/appointmentController');
const { auth } = require('../middleware/auth');

// GET /api/appointments - Get all appointments
router.get('/', auth, AppointmentController.getAll);

// GET /api/appointments/upcoming - Get upcoming appointments
router.get('/upcoming', auth, AppointmentController.getUpcoming);

// GET /api/appointments/:id - Get appointment by ID
router.get('/:id', auth, AppointmentController.getById);

// POST /api/appointments - Create new appointment
router.post('/', auth, AppointmentController.create);

// PUT /api/appointments/:id - Update appointment
router.put('/:id', auth, AppointmentController.update);

// DELETE /api/appointments/:id - Delete appointment
router.delete('/:id', auth, AppointmentController.delete);

module.exports = router;

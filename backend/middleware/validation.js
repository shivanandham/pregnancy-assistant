const Joi = require('joi');

// Validation schemas
const schemas = {
  pregnancy: Joi.object({
    dueDate: Joi.date().iso().required(),
    lastMenstrualPeriod: Joi.date().iso().required(),
    notes: Joi.string().max(1000).optional()
  }),

  symptom: Joi.object({
    type: Joi.string().valid(
      'nausea', 'fatigue', 'backPain', 'heartburn', 'moodSwings',
      'foodCravings', 'headaches', 'swollenFeet', 'insomnia',
      'frequentUrination', 'other'
    ).required(),
    severity: Joi.string().valid('mild', 'moderate', 'severe').required(),
    dateTime: Joi.date().iso().required(),
    notes: Joi.string().max(1000).optional(),
    customType: Joi.string().max(100).optional()
  }),

  appointment: Joi.object({
    title: Joi.string().min(1).max(200).required(),
    type: Joi.string().valid(
      'prenatal', 'ultrasound', 'bloodTest', 'glucoseTest',
      'consultation', 'other'
    ).required(),
    dateTime: Joi.date().iso().required(),
    location: Joi.string().max(200).optional(),
    doctor: Joi.string().max(100).optional(),
    notes: Joi.string().max(1000).optional()
  }),

  weightEntry: Joi.object({
    weight: Joi.number().positive().max(500).required(),
    dateTime: Joi.date().iso().required(),
    notes: Joi.string().max(1000).optional()
  }),

  chatMessage: Joi.object({
    message: Joi.string().min(1).max(2000).required(),
    context: Joi.string().max(500).optional()
  })
};

// Validation middleware factory
const validate = (schema) => {
  return (req, res, next) => {
    const { error } = schema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        details: error.details.map(detail => detail.message)
      });
    }
    
    next();
  };
};

module.exports = {
  schemas,
  validate
};

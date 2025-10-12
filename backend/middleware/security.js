const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Security middleware
const securityMiddleware = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  crossOriginEmbedderPolicy: false
});

// Rate limiting for API endpoints
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === 'development' ? 1000 : 100, // More lenient in development
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Rate limiting for chat endpoint (more restrictive)
const chatLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: process.env.NODE_ENV === 'development' ? 100 : 10, // More lenient in development
  message: {
    success: false,
    message: 'Too many chat requests, please wait a moment before trying again.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

module.exports = {
  securityMiddleware,
  apiLimiter,
  chatLimiter
};

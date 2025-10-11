const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Import database and middleware
const database = require('./config/database');
const { securityMiddleware, apiLimiter, chatLimiter } = require('./middleware/security');
const { validate, schemas } = require('./middleware/validation');
const Logger = require('./middleware/logger');

// Import routes
const pregnancyRoutes = require('./routes/pregnancy');
const symptomRoutes = require('./routes/symptoms');
const appointmentRoutes = require('./routes/appointments');
const weightRoutes = require('./routes/weight');
const chatRoutes = require('./routes/chat');
const knowledgeRoutes = require('./routes/knowledge');
const userProfileRoutes = require('./routes/userProfile');

const app = express();
const PORT = process.env.PORT || 3000;

// Check for required environment variables
if (!process.env.GEMINI_API_KEY) {
  console.error('GEMINI_API_KEY is required in environment variables');
  process.exit(1);
}

// Logging middleware (should be early in the chain)
app.use(Logger.logRequest);

// Security middleware
app.use(securityMiddleware);

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://your-app-domain.com'] // Replace with your app's domain
    : ['http://localhost:3000', 'http://localhost:8080'], // Development origins
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
app.use('/api', apiLimiter);
app.use('/api/chat', chatLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Luma Pregnancy Assistant Backend is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// API Routes
app.use('/api/pregnancy', pregnancyRoutes);
app.use('/api/symptoms', symptomRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/weight', weightRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/knowledge', knowledgeRoutes);
app.use('/api/user-profile', userProfileRoutes);

// Legacy chat endpoint for backward compatibility
app.post('/chat', async (req, res) => {
  try {
    const { message, week = null, context = '' } = req.body;

    if (!message) {
      return res.status(400).json({ 
        success: false,
        message: 'Message is required' 
      });
    }

    // Redirect to new chat API
    const chatController = require('./controllers/chatController');
    req.body.context = context;
    if (week) {
      req.body.context = `${context} Week ${week}`.trim();
    }
    
    return chatController.sendMessage(req, res);

  } catch (error) {
    console.error('Error in legacy chat endpoint:', error);
    
    res.status(500).json({
      success: false,
      message: 'Failed to get AI response',
      error: 'Please try again later'
    });
  }
});

// Error handling middleware
app.use(Logger.logError);
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { error: err.message })
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Initialize database and start server
async function startServer() {
  try {
    // Create data directory if it doesn't exist
    const fs = require('fs');
    const dataDir = path.join(__dirname, 'data');
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }

    // Initialize database
    await database.initialize();
    console.log('Database initialized successfully');

    // Start server
    app.listen(PORT, () => {
      console.log(`🚀 Luma Pregnancy Assistant Backend running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
      console.log(`💬 Chat API: http://localhost:${PORT}/api/chat`);
      console.log(`📱 API Base: http://localhost:${PORT}/api`);
    });

  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down server...');
  try {
    await database.close();
    console.log('✅ Database connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

process.on('SIGTERM', async () => {
  console.log('\n🛑 Received SIGTERM, shutting down gracefully...');
  try {
    await database.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

// Start the server
startServer();

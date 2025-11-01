const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Import Prisma client
// Prisma automatically reads DATABASE_URL from .env file
const prisma = require('./lib/prisma');

// Import middleware
const { securityMiddleware, apiLimiter, chatLimiter } = require('./middleware/security');
const { validate, schemas } = require('./middleware/validation');
const Logger = require('./middleware/logger');

// Import routes
const authRoutes = require('./routes/auth');
const pregnancyRoutes = require('./routes/pregnancy');
const symptomRoutes = require('./routes/symptoms');
const appointmentRoutes = require('./routes/appointments');
const weightRoutes = require('./routes/weight');
const chatRoutes = require('./routes/chat');
const chatSessionRoutes = require('./routes/chatSessions');
const knowledgeRoutes = require('./routes/knowledge');
const userProfileRoutes = require('./routes/userProfile');
const releaseRoutes = require('./routes/releases');
const tipsRoutes = require('./routes/tips');
const milestonesRoutes = require('./routes/milestones');
const checklistRoutes = require('./routes/checklist');

// Import services
const CronService = require('./services/cronService');

const app = express();
const PORT = process.env.PORT || 3000;

// Check for required environment variables
if (!process.env.GEMINI_API_KEY) {
  console.error('GEMINI_API_KEY is required in environment variables');
  process.exit(1);
}

if (!process.env.DATABASE_URL) {
  console.error('DATABASE_URL is required in environment variables');
  console.error('Please set DATABASE_URL in your .env file');
  console.error('Example: DATABASE_URL=postgresql://postgres:password@localhost:5432/pregnancy_assistant');
  process.exit(1);
}

// Logging middleware (should be early in the chain)
app.use(Logger.logRequest);

// Security middleware
app.use(securityMiddleware);

// CORS configuration
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? true // Allow all origins in production (you can restrict this later)
    : ['http://localhost:3000', 'http://localhost:8080'], // Development origins
  credentials: true
}));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// Rate limiting
app.use('/api', apiLimiter);
app.use('/api/chat', chatLimiter);

// Health check endpoint
app.get('/api/health', async (req, res) => {
  try {
    // Test database connection
    await prisma.$queryRaw`SELECT 1`;
    
    res.json({ 
      status: 'OK', 
      message: 'Luma Pregnancy Assistant Backend is running',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
      database: 'Connected',
      environment: process.env.NODE_ENV || 'development'
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      message: 'Database connection failed',
      timestamp: new Date().toISOString(),
      error: error.message
    });
  }
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/pregnancy', pregnancyRoutes);
app.use('/api/symptoms', symptomRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/weight', weightRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/chat-sessions', chatSessionRoutes);
app.use('/api/knowledge', knowledgeRoutes);
app.use('/api/user-profile', userProfileRoutes);
app.use('/api/home', require('./routes/home'));
app.use('/api/tips', tipsRoutes);
app.use('/api/milestones', milestonesRoutes);
app.use('/api/checklist', checklistRoutes);
app.use('/api/releases', releaseRoutes);

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
    console.log('🔗 Testing database connection...');
    
    // Test Prisma connection
    await prisma.$queryRaw`SELECT NOW() as current_time`;
    console.log('✅ Database connected successfully');
    
    // Get database info
    const dbInfo = await prisma.$queryRaw`
      SELECT 
        current_database() as database_name,
        version() as version
    `;
    
    console.log(`📊 Database: ${dbInfo[0].database_name}`);
    console.log(`🐘 PostgreSQL: ${dbInfo[0].version.split(' ')[0]}`);

    // Start server
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`🚀 Luma Pregnancy Assistant Backend running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
      console.log(`💬 Chat API: http://localhost:${PORT}/api/chat`);
      console.log(`📱 API Base: http://localhost:${PORT}/api`);
      console.log(`🗄️ Database: ${process.env.NODE_ENV === 'development' ? 'Local PostgreSQL' : 'Supabase PostgreSQL'}`);
      
      // Start cron jobs
      CronService.start();
    });

  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Shutting down server...');
  try {
    await prisma.$disconnect();
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
    await prisma.$disconnect();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during shutdown:', error);
    process.exit(1);
  }
});

// Start the server
startServer();
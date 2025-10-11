const fs = require('fs');
const path = require('path');

class Logger {
  static logRequest(req, res, next) {
    const timestamp = new Date().toISOString();
    const method = req.method;
    const url = req.originalUrl;
    const userAgent = req.get('User-Agent') || 'Unknown';
    const ip = req.ip || req.connection.remoteAddress || 'Unknown';
    
    // Log request
    console.log(`\n📥 [${timestamp}] ${method} ${url}`);
    console.log(`   IP: ${ip}`);
    console.log(`   User-Agent: ${userAgent}`);
    
    // Log request body for POST/PUT requests
    if (['POST', 'PUT', 'PATCH'].includes(method) && req.body) {
      console.log(`   Body: ${JSON.stringify(req.body, null, 2)}`);
    }
    
    // Log query parameters
    if (Object.keys(req.query).length > 0) {
      console.log(`   Query: ${JSON.stringify(req.query)}`);
    }
    
    // Capture original res.json to log responses
    const originalJson = res.json;
    res.json = function(data) {
      const responseTime = Date.now() - req.startTime;
      console.log(`📤 [${timestamp}] ${method} ${url} - ${res.statusCode} (${responseTime}ms)`);
      console.log(`   Response: ${JSON.stringify(data, null, 2)}`);
      console.log('─'.repeat(80));
      
      return originalJson.call(this, data);
    };
    
    // Set start time for response time calculation
    req.startTime = Date.now();
    
    next();
  }
  
  static logError(error, req, res, next) {
    const timestamp = new Date().toISOString();
    const method = req.method;
    const url = req.originalUrl;
    
    console.log(`\n❌ [${timestamp}] ERROR in ${method} ${url}`);
    console.log(`   Error: ${error.message}`);
    console.log(`   Stack: ${error.stack}`);
    console.log('─'.repeat(80));
    
    next(error);
  }
  
  static logDatabase(operation, table, data = null) {
    const timestamp = new Date().toISOString();
    console.log(`\n🗄️  [${timestamp}] DB ${operation.toUpperCase()} on ${table}`);
    if (data) {
      console.log(`   Data: ${JSON.stringify(data, null, 2)}`);
    }
  }
}

module.exports = Logger;

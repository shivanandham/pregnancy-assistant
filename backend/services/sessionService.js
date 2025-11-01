const jwt = require('jsonwebtoken');
const prisma = require('../lib/prisma');
const crypto = require('crypto');

class SessionService {
  /**
   * Generate session token and refresh token for a user
   * @param {string} userId - User ID
   * @param {object} deviceInfo - Optional device information (device name, IP, user agent)
   * @returns {Promise<{sessionToken: string, refreshToken: string, expiresAt: Date, refreshExpiresAt: Date, sessionId: string}>}
   */
  static async generateSessionToken(userId, deviceInfo = null) {
    const sessionId = crypto.randomUUID();
    const now = new Date();
    
    // Get expiration times from environment or use defaults
    const sessionExpiresIn = process.env.JWT_EXPIRES_IN || '30d';
    const refreshExpiresIn = process.env.JWT_REFRESH_EXPIRES_IN || '90d';
    
    // Calculate expiration dates
    const expiresAt = new Date(now);
    const refreshExpiresAt = new Date(now);
    
    // Parse expiration strings (e.g., "30d", "90d", "1h", "30m")
    if (sessionExpiresIn.endsWith('d')) {
      const days = parseInt(sessionExpiresIn);
      expiresAt.setDate(expiresAt.getDate() + days);
    } else if (sessionExpiresIn.endsWith('h')) {
      const hours = parseInt(sessionExpiresIn);
      expiresAt.setHours(expiresAt.getHours() + hours);
    } else if (sessionExpiresIn.endsWith('m')) {
      const minutes = parseInt(sessionExpiresIn);
      expiresAt.setMinutes(expiresAt.getMinutes() + minutes);
    } else if (sessionExpiresIn.endsWith('s')) {
      const seconds = parseInt(sessionExpiresIn);
      expiresAt.setSeconds(expiresAt.getSeconds() + seconds);
    } else {
      // Default to 30 days
      expiresAt.setDate(expiresAt.getDate() + 30);
    }
    
    if (refreshExpiresIn.endsWith('d')) {
      const days = parseInt(refreshExpiresIn);
      refreshExpiresAt.setDate(refreshExpiresAt.getDate() + days);
    } else if (refreshExpiresIn.endsWith('h')) {
      const hours = parseInt(refreshExpiresIn);
      refreshExpiresAt.setHours(refreshExpiresAt.getHours() + hours);
    } else if (refreshExpiresIn.endsWith('m')) {
      const minutes = parseInt(refreshExpiresIn);
      refreshExpiresAt.setMinutes(refreshExpiresAt.getMinutes() + minutes);
    } else if (refreshExpiresIn.endsWith('s')) {
      const seconds = parseInt(refreshExpiresIn);
      refreshExpiresAt.setSeconds(refreshExpiresAt.getSeconds() + seconds);
    } else {
      // Default to 90 days
      refreshExpiresAt.setDate(refreshExpiresAt.getDate() + 90);
    }
    
    // Generate JWT session token
    const sessionToken = jwt.sign(
      {
        userId,
        sessionId,
        iat: Math.floor(now.getTime() / 1000),
        exp: Math.floor(expiresAt.getTime() / 1000)
      },
      process.env.JWT_SECRET,
      { algorithm: 'HS256' }
    );
    
    // Generate refresh token (longer random string)
    const refreshToken = crypto.randomBytes(64).toString('hex');
    
    // Store session in database
    const session = await prisma.session.create({
      data: {
        id: sessionId,
        userId,
        token: sessionToken,
        refreshToken,
        expiresAt,
        refreshExpiresAt,
        deviceInfo,
        lastUsedAt: now
      }
    });
    
    return {
      sessionToken,
      refreshToken,
      expiresAt,
      refreshExpiresAt,
      sessionId: session.id
    };
  }
  
  /**
   * Verify session token
   * @param {string} token - JWT session token
   * @returns {Promise<{valid: boolean, session?: object, error?: string}>}
   */
  static async verifySessionToken(token) {
    try {
      // Verify JWT signature and expiration
      const decoded = jwt.verify(token, process.env.JWT_SECRET, { algorithms: ['HS256'] });
      
      // Find session in database
      const session = await prisma.session.findUnique({
        where: { token },
        include: { user: true }
      });
      
      if (!session) {
        return { valid: false, error: 'Session not found' };
      }
      
      // Check if session is revoked
      if (session.isRevoked) {
        return { valid: false, error: 'Session revoked' };
      }
      
      // Check if session is expired (double-check)
      if (new Date() > session.expiresAt) {
        return { valid: false, error: 'Session expired' };
      }
      
      // Verify session ID matches
      if (decoded.sessionId !== session.id) {
        return { valid: false, error: 'Invalid session ID' };
      }
      
      // Update last used timestamp
      await prisma.session.update({
        where: { id: session.id },
        data: { lastUsedAt: new Date() }
      });
      
      return {
        valid: true,
        session: {
          id: session.id,
          userId: session.userId,
          user: session.user
        }
      };
    } catch (error) {
      if (error.name === 'JsonWebTokenError') {
        return { valid: false, error: 'Invalid token' };
      }
      if (error.name === 'TokenExpiredError') {
        return { valid: false, error: 'Token expired' };
      }
      return { valid: false, error: error.message };
    }
  }
  
  /**
   * Refresh session token using refresh token
   * @param {string} refreshToken - Refresh token
   * @returns {Promise<{success: boolean, sessionToken?: string, refreshToken?: string, expiresAt?: Date, refreshExpiresAt?: Date, error?: string}>}
   */
  static async refreshSessionToken(refreshToken) {
    try {
      // Find session by refresh token
      const session = await prisma.session.findUnique({
        where: { refreshToken },
        include: { user: true }
      });
      
      if (!session) {
        return { success: false, error: 'Invalid refresh token' };
      }
      
      // Check if session is revoked
      if (session.isRevoked) {
        return { success: false, error: 'Session revoked' };
      }
      
      // Check if refresh token is expired
      if (new Date() > session.refreshExpiresAt) {
        return { success: false, error: 'Refresh token expired' };
      }
      
      // Revoke old session
      await prisma.session.update({
        where: { id: session.id },
        data: { isRevoked: true }
      });
      
      // Generate new session token (token rotation)
      const deviceInfo = session.deviceInfo;
      const newSession = await this.generateSessionToken(session.userId, deviceInfo);
      
      return {
        success: true,
        sessionToken: newSession.sessionToken,
        refreshToken: newSession.refreshToken,
        expiresAt: newSession.expiresAt,
        refreshExpiresAt: newSession.refreshExpiresAt
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
  
  /**
   * Revoke a specific session
   * @param {string} sessionId - Session ID
   * @returns {Promise<{success: boolean, error?: string}>}
   */
  static async revokeSession(sessionId) {
    try {
      await prisma.session.update({
        where: { id: sessionId },
        data: { isRevoked: true }
      });
      
      return { success: true };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
  
  /**
   * Revoke all sessions for a user
   * @param {string} userId - User ID
   * @returns {Promise<{success: boolean, count?: number, error?: string}>}
   */
  static async revokeAllUserSessions(userId) {
    try {
      const result = await prisma.session.updateMany({
        where: {
          userId,
          isRevoked: false
        },
        data: { isRevoked: true }
      });
      
      return { success: true, count: result.count };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
  
  /**
   * Clean up expired sessions (for cron job)
   * @returns {Promise<{deleted: number}>}
   */
  static async cleanupExpiredSessions() {
    try {
      const now = new Date();
      
      // Delete expired sessions older than 7 days
      const cutoffDate = new Date(now);
      cutoffDate.setDate(cutoffDate.getDate() - 7);
      
      const result = await prisma.session.deleteMany({
        where: {
          OR: [
            { expiresAt: { lt: cutoffDate } },
            { 
              AND: [
                { isRevoked: true },
                { updatedAt: { lt: cutoffDate } }
              ]
            }
          ]
        }
      });
      
      return { deleted: result.count };
    } catch (error) {
      console.error('Error cleaning up expired sessions:', error);
      return { deleted: 0 };
    }
  }
}

module.exports = SessionService;


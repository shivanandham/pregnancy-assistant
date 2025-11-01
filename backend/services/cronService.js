const cron = require('node-cron');
const DailyChecklist = require('../models/DailyChecklist');
const Pregnancy = require('../models/Pregnancy');
const UserProfile = require('../models/UserProfile');
const SessionService = require('./sessionService');

class CronService {
  static start() {
    console.log('🕐 Starting cron jobs...');
    
    // Generate daily checklists at 12:00 AM IST (6:30 PM UTC)
    // IST is UTC+5:30, so 12:00 AM IST = 6:30 PM UTC (previous day)
    cron.schedule('30 18 * * *', async () => {
      console.log('🔄 Running daily checklist generation job...');
      await this.generateDailyChecklists();
    }, {
      timezone: 'Asia/Kolkata'
    });

    // Clean up expired sessions daily at 2:00 AM IST (8:30 PM UTC previous day)
    cron.schedule('30 20 * * *', async () => {
      console.log('🔄 Running session cleanup job...');
      await this.cleanupExpiredSessions();
    }, {
      timezone: 'Asia/Kolkata'
    });

    console.log('✅ Cron jobs started successfully');
    console.log('📅 Daily checklist generation scheduled for 12:00 AM IST');
    console.log('🧹 Session cleanup scheduled for 2:00 AM IST');
  }

  static async generateDailyChecklists() {
    try {
      console.log('🎯 Generating daily checklists for all users...');
      
      // Get current pregnancy data
      const pregnancy = await Pregnancy.getCurrent();
      if (!pregnancy) {
        console.log('⚠️  No pregnancy data found, skipping checklist generation');
        return;
      }

      // Get user profile
      const userProfile = await UserProfile.get();
      if (!userProfile) {
        console.log('⚠️  No user profile found, skipping checklist generation');
        return;
      }

      // Generate new daily checklist
      const today = new Date();
      const newChecklist = await DailyChecklist.generateDynamicChecklist(pregnancy, userProfile, today);
      
      console.log(`✅ Generated ${newChecklist.length} personalized checklist items for ${today.toDateString()}`);
      
      // Log some sample tasks
      if (newChecklist.length > 0) {
        console.log('📋 Sample tasks generated:');
        newChecklist.slice(0, 3).forEach((task, index) => {
          console.log(`   ${index + 1}. ${task.task}`);
        });
      }

    } catch (error) {
      console.error('❌ Error generating daily checklists:', error);
    }
  }

  // Manual trigger for testing
  static async triggerDailyChecklistGeneration() {
    console.log('🧪 Manually triggering daily checklist generation...');
    await this.generateDailyChecklists();
  }

  static async cleanupExpiredSessions() {
    try {
      console.log('🧹 Cleaning up expired sessions...');
      const result = await SessionService.cleanupExpiredSessions();
      console.log(`✅ Cleaned up ${result.deleted} expired session(s)`);
    } catch (error) {
      console.error('❌ Error cleaning up expired sessions:', error);
    }
  }
}

module.exports = CronService;

const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

class ChecklistCompletion {
  constructor(data) {
    this.id = data.id;
    this.checklistItemId = data.checklistItemId;
    this.completedAt = data.completedAt;
    this.date = data.date;
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  // Save completion to database
  async save() {
    try {
      const savedCompletion = await prisma.checklistCompletion.upsert({
        where: {
          checklistItemId_date: {
            checklistItemId: this.checklistItemId,
            date: this.date
          }
        },
        update: {
          completedAt: this.completedAt,
          updatedAt: new Date()
        },
        create: {
          checklistItemId: this.checklistItemId,
          completedAt: this.completedAt,
          date: this.date
        }
      });
      
      return new ChecklistCompletion(savedCompletion);
    } catch (error) {
      console.error('Error saving checklist completion:', error);
      throw error;
    }
  }

  // Delete completion from database
  async delete() {
    try {
      await prisma.checklistCompletion.delete({
        where: {
          checklistItemId_date: {
            checklistItemId: this.checklistItemId,
            date: this.date
          }
        }
      });
      return true;
    } catch (error) {
      console.error('Error deleting checklist completion:', error);
      throw error;
    }
  }

  // Get completions for a specific date
  static async getCompletionsForDate(date) {
    try {
      const completions = await prisma.checklistCompletion.findMany({
        where: {
          date: date
        }
      });
      
      return completions.map(completion => new ChecklistCompletion(completion));
    } catch (error) {
      console.error('Error getting completions for date:', error);
      throw error;
    }
  }

  // Get completions for a date range
  static async getCompletionsForDateRange(startDate, endDate) {
    try {
      const completions = await prisma.checklistCompletion.findMany({
        where: {
          date: {
            gte: startDate,
            lte: endDate
          }
        }
      });
      
      return completions.map(completion => new ChecklistCompletion(completion));
    } catch (error) {
      console.error('Error getting completions for date range:', error);
      throw error;
    }
  }

  // Check if a specific item is completed for a date
  static async isCompleted(checklistItemId, date) {
    try {
      const completion = await prisma.checklistCompletion.findUnique({
        where: {
          checklistItemId_date: {
            checklistItemId: checklistItemId,
            date: date
          }
        }
      });
      
      return !!completion;
    } catch (error) {
      console.error('Error checking completion status:', error);
      throw error;
    }
  }

  toJSON() {
    return {
      id: this.id,
      checklistItemId: this.checklistItemId,
      completedAt: this.completedAt,
      date: this.date,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }
}

module.exports = ChecklistCompletion;

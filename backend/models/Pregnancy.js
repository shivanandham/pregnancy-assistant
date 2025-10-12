const prisma = require('../lib/prisma');

class Pregnancy {
  constructor(data) {
    this.id = data.id;
    this.dueDate = new Date(data.dueDate);
    this.lastMenstrualPeriod = new Date(data.lastMenstrualPeriod);
    this.notes = data.notes;
    this.createdAt = data.createdAt ? new Date(data.createdAt) : new Date();
    this.updatedAt = data.updatedAt ? new Date(data.updatedAt) : new Date();
  }

  // Calculate current week of pregnancy
  getCurrentWeek() {
    const now = new Date();
    const lmp = new Date(this.lastMenstrualPeriod);
    const daysSinceLMP = Math.floor((now - lmp) / (1000 * 60 * 60 * 24));
    return Math.floor(daysSinceLMP / 7) + 1;
  }

  // Calculate days until due date
  getDaysUntilDueDate() {
    const now = new Date();
    const dueDate = new Date(this.dueDate);
    return Math.ceil((dueDate - now) / (1000 * 60 * 60 * 24));
  }

  // Get current trimester
  getCurrentTrimester() {
    const week = this.getCurrentWeek();
    if (week <= 12) return 1;
    if (week <= 28) return 2;
    return 3;
  }

  // Get progress percentage
  getProgressPercentage() {
    const lmp = new Date(this.lastMenstrualPeriod);
    const dueDate = new Date(this.dueDate);
    const now = new Date();
    const totalDays = Math.floor((dueDate - lmp) / (1000 * 60 * 60 * 24));
    const elapsedDays = Math.floor((now - lmp) / (1000 * 60 * 60 * 24));
    return Math.min(Math.max(elapsedDays / totalDays, 0), 1);
  }

  async save() {
    const data = {
      dueDate: new Date(this.dueDate),
      lastMenstrualPeriod: new Date(this.lastMenstrualPeriod),
      notes: this.notes,
    };

    if (this.id) {
      // Update existing pregnancy
      const updated = await prisma.pregnancyData.update({
        where: { id: this.id },
        data: data,
      });
      return new Pregnancy(updated);
    } else {
      // Create new pregnancy
      const created = await prisma.pregnancyData.create({
        data: data,
      });
      return new Pregnancy(created);
    }
  }

  static async getCurrent() {
    const pregnancy = await prisma.pregnancyData.findFirst({
      orderBy: { createdAt: 'desc' },
    });
    
    if (pregnancy) {
      return new Pregnancy(pregnancy);
    }
    
    return null;
  }

  static async delete(id) {
    await prisma.pregnancyData.delete({
      where: { id },
    });
  }

  toJSON() {
    return {
      id: this.id,
      dueDate: this.dueDate,
      lastMenstrualPeriod: this.lastMenstrualPeriod,
      notes: this.notes,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      currentWeek: this.getCurrentWeek(),
      daysUntilDueDate: this.getDaysUntilDueDate(),
      currentTrimester: this.getCurrentTrimester(),
      progressPercentage: this.getProgressPercentage()
    };
  }
}

module.exports = Pregnancy;
const prisma = require('../lib/prisma');

class WeightEntry {
  constructor(data) {
    this.id = data.id;
    this.weight = data.weight;
    this.dateTime = data.dateTime;
    this.notes = data.notes;
    this.createdAt = data.createdAt;
  }

  // Convert kg to lbs
  getWeightInPounds() {
    return this.weight * 2.20462;
  }

  async save() {
    const data = {
      weight: this.weight,
      dateTime: this.dateTime,
      notes: this.notes,
    };

    if (this.id) {
      // Update existing weight entry
      const updated = await prisma.weightEntry.update({
        where: { id: this.id },
        data: data,
      });
      return new WeightEntry(updated);
    } else {
      // Create new weight entry
      const created = await prisma.weightEntry.create({
        data: data,
      });
      return new WeightEntry(created);
    }
  }

  static async getAll() {
    const weightEntries = await prisma.weightEntry.findMany({
      orderBy: { dateTime: 'desc' },
    });
    
    return weightEntries.map(entry => new WeightEntry(entry));
  }

  static async getById(id) {
    const weightEntry = await prisma.weightEntry.findUnique({
      where: { id },
    });
    
    if (weightEntry) {
      return new WeightEntry(weightEntry);
    }
    
    return null;
  }

  static async getByDateRange(startDate, endDate) {
    const weightEntries = await prisma.weightEntry.findMany({
      where: {
        dateTime: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: { dateTime: 'desc' },
    });
    
    return weightEntries.map(entry => new WeightEntry(entry));
  }

  static async delete(id) {
    await prisma.weightEntry.delete({
      where: { id },
    });
  }

  toJSON() {
    return {
      id: this.id,
      weight: this.weight,
      dateTime: this.dateTime,
      notes: this.notes,
      createdAt: this.createdAt,
      weightInPounds: this.getWeightInPounds()
    };
  }
}

module.exports = WeightEntry;
const prisma = require('../lib/prisma');

class Symptom {
  constructor(data) {
    this.id = data.id;
    this.type = data.type;
    this.severity = data.severity;
    this.dateTime = data.dateTime;
    this.notes = data.notes;
    this.customType = data.customType;
    this.createdAt = data.createdAt;
  }

  getDisplayName() {
    if (this.type === 'other' && this.customType) {
      return this.customType;
    }
    return this.type.replace(/([A-Z])/g, ' $1').trim();
  }

  async save() {
    const data = {
      type: this.type,
      severity: this.severity,
      dateTime: this.dateTime,
      notes: this.notes,
      customType: this.customType,
    };

    if (this.id) {
      // Update existing symptom
      const updated = await prisma.symptom.update({
        where: { id: this.id },
        data: data,
      });
      return new Symptom(updated);
    } else {
      // Create new symptom
      const created = await prisma.symptom.create({
        data: data,
      });
      return new Symptom(created);
    }
  }

  static async getAll() {
    const symptoms = await prisma.symptom.findMany({
      orderBy: { dateTime: 'desc' },
    });
    
    return symptoms.map(symptom => new Symptom(symptom));
  }

  static async getById(id) {
    const symptom = await prisma.symptom.findUnique({
      where: { id },
    });
    
    if (symptom) {
      return new Symptom(symptom);
    }
    
    return null;
  }

  static async getByDateRange(startDate, endDate) {
    const symptoms = await prisma.symptom.findMany({
      where: {
        dateTime: {
          gte: startDate,
          lte: endDate,
        },
      },
      orderBy: { dateTime: 'desc' },
    });
    
    return symptoms.map(symptom => new Symptom(symptom));
  }

  static async delete(id) {
    await prisma.symptom.delete({
      where: { id },
    });
  }

  toJSON() {
    return {
      id: this.id,
      type: this.type,
      severity: this.severity,
      dateTime: this.dateTime,
      notes: this.notes,
      customType: this.customType,
      createdAt: this.createdAt,
      displayName: this.getDisplayName()
    };
  }
}

module.exports = Symptom;
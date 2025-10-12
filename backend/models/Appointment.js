const prisma = require('../lib/prisma');

class Appointment {
  constructor(data) {
    this.id = data.id; // Prisma will provide the id when creating/updating
    this.title = data.title;
    this.type = data.type;
    this.dateTime = data.dateTime;
    this.location = data.location;
    this.doctor = data.doctor;
    this.notes = data.notes;
    this.isCompleted = data.isCompleted;
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  getDisplayName() {
    return this.type.replace(/([A-Z])/g, ' $1').trim();
  }

  isUpcoming() {
    const now = new Date();
    const appointmentDate = new Date(this.dateTime);
    return appointmentDate > now && !this.isCompleted;
  }

  isPast() {
    const now = new Date();
    const appointmentDate = new Date(this.dateTime);
    return appointmentDate < now || this.isCompleted;
  }

  async save() {
    const data = {
      title: this.title,
      type: this.type,
      dateTime: new Date(this.dateTime), // Convert to Date object for Prisma
      location: this.location,
      doctor: this.doctor,
      notes: this.notes,
      isCompleted: this.isCompleted,
    };

    if (this.id) {
      // Update existing appointment
      const updated = await prisma.appointment.update({
        where: { id: this.id },
        data: data,
      });
      return new Appointment(updated);
    } else {
      // Create new appointment
      const created = await prisma.appointment.create({
        data: data,
      });
      return new Appointment(created);
    }
  }

  static async getAll() {
    const appointments = await prisma.appointment.findMany({
      orderBy: { dateTime: 'asc' },
    });
    
    return appointments.map(appointment => new Appointment(appointment));
  }

  static async getById(id) {
    const appointment = await prisma.appointment.findUnique({
      where: { id },
    });
    
    if (appointment) {
      return new Appointment(appointment);
    }
    
    return null;
  }

  static async getUpcoming() {
    const now = new Date();
    const nextWeek = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    
    const appointments = await prisma.appointment.findMany({
      where: {
        dateTime: {
          gte: now,
          lte: nextWeek,
        },
        isCompleted: false,
      },
      orderBy: { dateTime: 'asc' },
    });
    
    return appointments.map(appointment => new Appointment(appointment));
  }

  static async delete(id) {
    await prisma.appointment.delete({
      where: { id },
    });
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      type: this.type,
      dateTime: this.dateTime,
      location: this.location,
      doctor: this.doctor,
      notes: this.notes,
      isCompleted: this.isCompleted,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      displayName: this.getDisplayName(),
      isUpcoming: this.isUpcoming(),
      isPast: this.isPast()
    };
  }
}

module.exports = Appointment;
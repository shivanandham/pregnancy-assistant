const prisma = require('../lib/prisma');

class UserProfile {
  constructor(data) {
    this.id = data.id;
    this.height = data.height;
    this.weight = data.weight;
    this.prePregnancyWeight = data.prePregnancyWeight;
    this.age = data.age;
    this.gender = data.gender || 'female';
    this.locality = data.locality;
    this.timezone = data.timezone;
    this.medicalHistory = data.medicalHistory;
    this.allergies = data.allergies;
    this.medications = data.medications;
    this.lifestyle = data.lifestyle;
    this.createdAt = data.createdAt;
    this.updatedAt = data.updatedAt;
  }

  async save() {
    const data = {
      height: this.height,
      weight: this.weight,
      prePregnancyWeight: this.prePregnancyWeight,
      age: this.age,
      gender: this.gender,
      locality: this.locality,
      timezone: this.timezone,
      medicalHistory: this.medicalHistory,
      allergies: this.allergies,
      medications: this.medications,
      lifestyle: this.lifestyle,
    };

    if (this.id) {
      // Update existing profile
      const updated = await prisma.userProfile.update({
        where: { id: this.id },
        data: data,
      });
      return new UserProfile(updated);
    } else {
      // Create new profile
      const created = await prisma.userProfile.create({
        data: data,
      });
      return new UserProfile(created);
    }
  }

  static async get() {
    const profile = await prisma.userProfile.findFirst();
    
    if (profile) {
      return new UserProfile(profile);
    }
    
    return null;
  }

  static async update(updates) {
    const existingProfile = await UserProfile.get();
    if (!existingProfile) {
      throw new Error('No user profile found');
    }

    const updated = await prisma.userProfile.update({
      where: { id: existingProfile.id },
      data: updates,
    });

    return new UserProfile(updated);
  }

  static async delete() {
    const existingProfile = await UserProfile.get();
    if (!existingProfile) {
      throw new Error('No user profile found');
    }

    await prisma.userProfile.delete({
      where: { id: existingProfile.id },
    });

    return true;
  }

  // Helper methods
  getBMI() {
    if (this.height && this.weight) {
      const heightInMeters = this.height / 100;
      return (this.weight / (heightInMeters * heightInMeters)).toFixed(1);
    }
    return null;
  }

  getWeightGain() {
    if (this.prePregnancyWeight && this.weight) {
      return (this.weight - this.prePregnancyWeight).toFixed(1);
    }
    return null;
  }

  getFormattedProfile() {
    const profile = [];
    
    if (this.age) profile.push(`Age: ${this.age} years`);
    if (this.height) profile.push(`Height: ${this.height} cm`);
    if (this.weight) profile.push(`Current weight: ${this.weight} kg`);
    if (this.prePregnancyWeight) profile.push(`Pre-pregnancy weight: ${this.prePregnancyWeight} kg`);
    if (this.getBMI()) profile.push(`BMI: ${this.getBMI()}`);
    if (this.getWeightGain()) profile.push(`Weight gain: ${this.getWeightGain()} kg`);
    if (this.locality) profile.push(`Location: ${this.locality}`);
    if (this.timezone) profile.push(`Timezone: ${this.timezone}`);
    
    return profile.join(', ');
  }

  getMedicalContext() {
    const context = [];
    
    if (this.medicalHistory && Array.isArray(this.medicalHistory) && this.medicalHistory.length > 0) {
      context.push(`Medical history: ${this.medicalHistory.join(', ')}`);
    }
    if (this.allergies && Array.isArray(this.allergies) && this.allergies.length > 0) {
      context.push(`Allergies: ${this.allergies.join(', ')}`);
    }
    if (this.medications && Array.isArray(this.medications) && this.medications.length > 0) {
      context.push(`Current medications: ${this.medications.join(', ')}`);
    }
    if (this.lifestyle && typeof this.lifestyle === 'object') {
      const lifestyleItems = [];
      if (this.lifestyle.diet) lifestyleItems.push(`Diet: ${this.lifestyle.diet}`);
      if (this.lifestyle.exercise) lifestyleItems.push(`Exercise: ${this.lifestyle.exercise}`);
      if (this.lifestyle.smoking) lifestyleItems.push(`Smoking: ${this.lifestyle.smoking}`);
      if (this.lifestyle.alcohol) lifestyleItems.push(`Alcohol: ${this.lifestyle.alcohol}`);
      if (lifestyleItems.length > 0) {
        context.push(`Lifestyle: ${lifestyleItems.join(', ')}`);
      }
    }
    
    return context.join('; ');
  }

  toJSON() {
    return {
      id: this.id,
      height: this.height,
      weight: this.weight,
      prePregnancyWeight: this.prePregnancyWeight,
      age: this.age,
      gender: this.gender,
      locality: this.locality,
      timezone: this.timezone,
      medicalHistory: this.medicalHistory,
      allergies: this.allergies,
      medications: this.medications,
      lifestyle: this.lifestyle,
      bmi: this.getBMI(),
      weightGain: this.getWeightGain(),
      createdAt: this.createdAt,
      updatedAt: this.updatedAt
    };
  }
}

module.exports = UserProfile;
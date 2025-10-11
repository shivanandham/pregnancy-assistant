const { v4: uuidv4 } = require('uuid');
const database = require('../config/database');

class UserProfile {
  constructor(data) {
    this.id = data.id || uuidv4();
    this.height = data.height || null; // in cm
    this.weight = data.weight || null; // in kg
    this.prePregnancyWeight = data.prePregnancyWeight || null; // in kg
    this.age = data.age || null;
    this.gender = data.gender || 'female'; // default to female for pregnancy app
    this.locality = data.locality || null; // city, country
    this.timezone = data.timezone || null;
    this.medicalHistory = data.medicalHistory || null; // JSON string
    this.allergies = data.allergies || null; // JSON string
    this.medications = data.medications || null; // JSON string
    this.lifestyle = data.lifestyle || null; // JSON string (diet, exercise, etc.)
    this.createdAt = data.createdAt || new Date().toISOString();
    this.updatedAt = data.updatedAt || new Date().toISOString();
  }

  async save() {
    const sql = `
      INSERT OR REPLACE INTO user_profiles 
      (id, height, weight, pre_pregnancy_weight, age, gender, locality, timezone, 
       medical_history, allergies, medications, lifestyle, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;
    
    await database.run(sql, [
      this.id,
      this.height,
      this.weight,
      this.prePregnancyWeight,
      this.age,
      this.gender,
      this.locality,
      this.timezone,
      this.medicalHistory ? JSON.stringify(this.medicalHistory) : null,
      this.allergies ? JSON.stringify(this.allergies) : null,
      this.medications ? JSON.stringify(this.medications) : null,
      this.lifestyle ? JSON.stringify(this.lifestyle) : null,
      this.createdAt,
      this.updatedAt
    ]);
    
    return this;
  }

  static async get() {
    const sql = 'SELECT * FROM user_profiles LIMIT 1';
    const row = await database.get(sql);
    
    if (row) {
      return new UserProfile({
        id: row.id,
        height: row.height,
        weight: row.weight,
        prePregnancyWeight: row.pre_pregnancy_weight,
        age: row.age,
        gender: row.gender,
        locality: row.locality,
        timezone: row.timezone,
        medicalHistory: row.medical_history ? JSON.parse(row.medical_history) : null,
        allergies: row.allergies ? JSON.parse(row.allergies) : null,
        medications: row.medications ? JSON.parse(row.medications) : null,
        lifestyle: row.lifestyle ? JSON.parse(row.lifestyle) : null,
        createdAt: row.created_at,
        updatedAt: row.updated_at
      });
    }
    
    return null;
  }

  static async update(updates) {
    const profile = await UserProfile.get();
    if (!profile) {
      throw new Error('No user profile found');
    }

    // Update fields
    Object.keys(updates).forEach(key => {
      if (updates[key] !== undefined) {
        profile[key] = updates[key];
      }
    });

    profile.updatedAt = new Date().toISOString();
    await profile.save();
    return profile;
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
    
    if (this.medicalHistory && this.medicalHistory.length > 0) {
      context.push(`Medical history: ${this.medicalHistory.join(', ')}`);
    }
    if (this.allergies && this.allergies.length > 0) {
      context.push(`Allergies: ${this.allergies.join(', ')}`);
    }
    if (this.medications && this.medications.length > 0) {
      context.push(`Current medications: ${this.medications.join(', ')}`);
    }
    if (this.lifestyle) {
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

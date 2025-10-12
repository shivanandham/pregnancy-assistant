const UserProfile = require('../models/UserProfile');
const Pregnancy = require('../models/Pregnancy');
const prisma = require('../lib/prisma');

async function populateSampleData() {
  try {
    console.log('🌱 Populating sample data...');
    
    // Create a user profile
    const profile = new UserProfile({
      height: 165.0,
      weight: 62.0,
      prePregnancyWeight: 58.0,
      age: 28,
      gender: 'female',
      locality: 'Mumbai, India',
      timezone: 'Asia/Kolkata',
      medicalHistory: ['gestational diabetes', 'mild anemia'],
      allergies: ['shellfish', 'pollen'],
      medications: ['prenatal vitamins', 'iron supplements'],
      lifestyle: {
        diet: 'vegetarian with fish',
        exercise: 'prenatal yoga 3x/week',
        smoking: 'never',
        alcohol: 'none during pregnancy'
      }
    });
    
    const savedProfile = await profile.save();
    console.log('✅ User profile created:', savedProfile.id);
    
    // Create pregnancy data
    const pregnancy = new Pregnancy({
      dueDate: new Date('2025-07-15'),
      lastMenstrualPeriod: new Date('2024-10-08'),
      notes: 'First pregnancy, very excited!'
    });
    
    const savedPregnancy = await pregnancy.save();
    console.log('✅ Pregnancy data created:', savedPregnancy.id);
    console.log('📅 Current week:', savedPregnancy.getCurrentWeek());
    
    // Add some symptoms
    const symptoms = [
      {
        type: 'morning_sickness',
        severity: 'moderate',
        dateTime: new Date('2024-10-15T08:00:00Z'),
        notes: 'Nausea in the morning, better after eating'
      },
      {
        type: 'fatigue',
        severity: 'mild',
        dateTime: new Date('2024-10-16T14:00:00Z'),
        notes: 'Feeling tired in the afternoon'
      },
      {
        type: 'food_craving',
        severity: 'mild',
        dateTime: new Date('2024-10-17T19:00:00Z'),
        notes: 'Craving pickles and ice cream'
      }
    ];
    
    for (const symptom of symptoms) {
      await prisma.symptom.create({ data: symptom });
    }
    console.log('✅ Symptoms added');
    
    // Add some appointments
    const appointments = [
      {
        title: 'First Prenatal Visit',
        type: 'prenatal',
        dateTime: new Date('2024-10-20T10:00:00Z'),
        location: 'City Hospital',
        doctor: 'Dr. Sarah Johnson',
        notes: 'Initial checkup and blood tests'
      },
      {
        title: 'Ultrasound Scan',
        type: 'ultrasound',
        dateTime: new Date('2024-11-15T14:30:00Z'),
        location: 'Radiology Center',
        doctor: 'Dr. Michael Chen',
        notes: 'First trimester screening'
      }
    ];
    
    for (const appointment of appointments) {
      await prisma.appointment.create({ data: appointment });
    }
    console.log('✅ Appointments added');
    
    // Add some weight entries
    const weightEntries = [
      {
        weight: 58.0,
        dateTime: new Date('2024-10-08T08:00:00Z'),
        notes: 'Pre-pregnancy weight'
      },
      {
        weight: 58.5,
        dateTime: new Date('2024-10-15T08:00:00Z'),
        notes: 'Week 1'
      },
      {
        weight: 59.0,
        dateTime: new Date('2024-10-22T08:00:00Z'),
        notes: 'Week 2'
      },
      {
        weight: 62.0,
        dateTime: new Date('2024-11-05T08:00:00Z'),
        notes: 'Current weight'
      }
    ];
    
    for (const entry of weightEntries) {
      await prisma.weightEntry.create({ data: entry });
    }
    console.log('✅ Weight entries added');
    
    // Add some chat messages
    const chatMessages = [
      {
        content: 'Hello! I just found out I\'m pregnant and I\'m so excited!',
        type: 'user',
        timestamp: new Date('2024-10-10T09:00:00Z'),
        context: 'First time user, just discovered pregnancy'
      },
      {
        content: 'Congratulations on your pregnancy! That\'s wonderful news. I\'m here to help you through this journey. How are you feeling so far?',
        type: 'assistant',
        timestamp: new Date('2024-10-10T09:01:00Z'),
        context: 'Welcome message, asking about current state'
      },
      {
        content: 'I\'ve been feeling a bit nauseous in the mornings. Is this normal?',
        type: 'user',
        timestamp: new Date('2024-10-15T08:30:00Z'),
        context: 'User asking about morning sickness'
      },
      {
        content: 'Yes, morning sickness is very common in early pregnancy! It typically starts around week 6 and can last until week 12-14. Here are some tips to help manage it...',
        type: 'assistant',
        timestamp: new Date('2024-10-15T08:31:00Z'),
        context: 'Providing advice about morning sickness management'
      }
    ];
    
    for (const message of chatMessages) {
      await prisma.chatMessage.create({ data: message });
    }
    console.log('✅ Chat messages added');
    
    console.log('\n🎉 Sample data populated successfully!');
    console.log('📊 You can now explore the data in Prisma Studio at http://localhost:5555');
    
  } catch (error) {
    console.error('❌ Failed to populate sample data:', error.message);
  }
}

populateSampleData();

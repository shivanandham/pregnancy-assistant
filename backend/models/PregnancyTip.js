const prisma = require('../lib/prisma');

class PregnancyTip {
  constructor(data) {
    this.id = data.id;
    this.week = data.week;
    this.tip = data.tip;
    this.category = data.category;
    this.createdAt = data.createdAt;
    this.expiresAt = data.expiresAt;
  }

  static async getTipsForWeek(week) {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

    // Check if we have cached tips for this week and today
    const existingTips = await prisma.pregnancyTip.findMany({
      where: {
        week: week,
        createdAt: {
          gte: startOfDay,
          lt: endOfDay
        }
      },
      orderBy: { createdAt: 'asc' }
    });

    if (existingTips.length >= 10) {
      return existingTips.map(tip => new PregnancyTip(tip));
    }

    // If we don't have enough tips, generate new ones with Gemini
    try {
      return await this.generateTipsForWeek(week);
    } catch (error) {
      console.error(`Failed to generate tips for week ${week}:`, error);
      throw new Error(`Unable to generate pregnancy tips for week ${week}. Please try again later.`);
    }
  }

  static async generateTipsForWeek(week) {
    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    try {
      const prompt = `Generate 10 helpful pregnancy tips for week ${week}. Return only a JSON array with this exact format:
[
  {"tip": "Stay hydrated by drinking 8-10 glasses of water daily", "category": "nutrition"},
  {"tip": "Take prenatal vitamins consistently", "category": "health"},
  {"tip": "Get plenty of rest and listen to your body", "category": "health"},
  {"tip": "Practice gentle stretching or prenatal yoga", "category": "exercise"},
  {"tip": "Eat small, frequent meals to help with nausea", "category": "nutrition"},
  {"tip": "Keep a pregnancy journal to track symptoms", "category": "emotional"},
  {"tip": "Avoid raw fish and unpasteurized dairy", "category": "nutrition"},
  {"tip": "Start thinking about your birth plan", "category": "preparation"},
  {"tip": "Practice deep breathing for relaxation", "category": "emotional"},
  {"tip": "Bond with your baby through gentle belly rubs", "category": "emotional"}
]

Make tips specific to week ${week} of pregnancy. Use categories: nutrition, health, exercise, emotional, preparation.`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      
      console.log('Gemini response:', text);
      
      // Clean the response text (remove markdown formatting if present)
      const cleanText = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      
      // Parse the JSON response
      const tipsData = JSON.parse(cleanText);
      
      if (!Array.isArray(tipsData) || tipsData.length === 0) {
        throw new Error('Invalid response format from Gemini');
      }
      
      // Save tips to database
      const savedTips = [];
      for (const tipData of tipsData) {
        if (tipData.tip && tipData.category) {
          const saved = await prisma.pregnancyTip.create({
            data: {
              week: week,
              tip: tipData.tip,
              category: tipData.category,
              expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // Expires in 24 hours
            }
          });
          savedTips.push(new PregnancyTip(saved));
        }
      }
      
      console.log(`Successfully generated ${savedTips.length} tips for week ${week}`);
      return savedTips;
    } catch (error) {
      console.error('Error generating pregnancy tips with Gemini:', error);
      throw error; // Don't use fallback, let the error propagate
    }
  }

  static async getFallbackTips(week) {
    const fallbackTips = [
      {
        tip: "Stay hydrated by drinking at least 8-10 glasses of water daily.",
        category: "nutrition"
      },
      {
        tip: "Take your prenatal vitamins consistently at the same time each day.",
        category: "health"
      },
      {
        tip: "Get plenty of rest and listen to your body when you feel tired.",
        category: "health"
      },
      {
        tip: "Practice gentle stretching or prenatal yoga to stay flexible.",
        category: "exercise"
      },
      {
        tip: "Eat small, frequent meals to help with nausea and maintain energy.",
        category: "nutrition"
      },
      {
        tip: "Keep a pregnancy journal to track your symptoms and feelings.",
        category: "emotional"
      },
      {
        tip: "Avoid raw fish, unpasteurized dairy, and deli meats.",
        category: "nutrition"
      },
      {
        tip: "Start thinking about your birth plan and discuss options with your healthcare provider.",
        category: "preparation"
      },
      {
        tip: "Practice deep breathing exercises for relaxation and stress management.",
        category: "emotional"
      },
      {
        tip: "Take time to bond with your baby through gentle belly rubs and talking.",
        category: "emotional"
      }
    ];

    const savedTips = [];
    for (const tipData of fallbackTips) {
      const saved = await prisma.pregnancyTip.create({
        data: {
          week: week,
          tip: tipData.tip,
          category: tipData.category,
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000)
        }
      });
      savedTips.push(new PregnancyTip(saved));
    }
    
    return savedTips;
  }

  static async clearExpiredTips() {
    await prisma.pregnancyTip.deleteMany({
      where: {
        expiresAt: {
          lt: new Date()
        }
      }
    });
  }

  toJSON() {
    return {
      id: this.id,
      week: this.week,
      tip: this.tip,
      category: this.category,
      createdAt: this.createdAt,
      expiresAt: this.expiresAt
    };
  }
}

module.exports = PregnancyTip;

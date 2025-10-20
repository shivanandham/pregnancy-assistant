const { GoogleGenerativeAI } = require('@google/generative-ai');

class DailyChecklist {
  constructor(data) {
    this.id = data.id;
    this.task = data.task;
    this.category = data.category;
    this.week = data.week;
    this.trimester = data.trimester;
    this.frequency = data.frequency; // 'daily', 'weekly', 'as_needed'
    this.important = data.important || false;
    this.personalized = data.personalized || false;
    this.generatedAt = data.generatedAt;
  }

  static async generateDynamicChecklist(pregnancy, userProfile, date = new Date()) {
    try {
      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      // Calculate current week from LMP
      const currentWeek = this.calculateCurrentWeek(pregnancy.lastMenstrualPeriod);
      const trimester = this.getTrimester(currentWeek);
      const daysRemaining = this.calculateDaysUntilDueDate(pregnancy.dueDate);
      
      // Get user context
      const userContext = userProfile ? `
        User Profile:
        - Height: ${userProfile.height || 'Not specified'}
        - Weight: ${userProfile.weight || 'Not specified'}
        - Age: ${userProfile.age || 'Not specified'}
        - Location: ${userProfile.location || 'Not specified'}
        - Medical Conditions: ${userProfile.medicalConditions || 'None'}
        - Allergies: ${userProfile.allergies || 'None'}
        - Dietary Preferences: ${userProfile.dietaryPreferences || 'None'}
        - Activity Level: ${userProfile.activityLevel || 'Not specified'}
      ` : 'No user profile available';

      const safeDueDate = pregnancy.dueDate ? new Date(pregnancy.dueDate) : null;
      const safeToday = date ? new Date(date) : new Date();

      const prompt = `
        You are a pregnancy assistant AI. Generate a personalized daily checklist for a pregnant woman.

        Pregnancy Context:
        - Current Week: ${currentWeek}
        - Trimester: ${trimester}
        - Days Remaining: ${daysRemaining}
        - Due Date: ${safeDueDate ? safeDueDate.toDateString() : 'Unknown'}
        - Current Date: ${safeToday.toDateString()}

        ${userContext}

        Generate 8-12 personalized daily checklist items that are:
        1. Relevant to her current pregnancy week (${currentWeek})
        2. Tailored to her trimester (${trimester})
        3. Considerate of her personal profile and preferences
        4. Practical and actionable for today
        5. Include both health, nutrition, and emotional well-being items
        6. Mix of essential daily tasks and week-specific recommendations

        For each item, provide:
        - A clear, actionable task description
        - Category (health, nutrition, exercise, emotional, preparation, self-care)
        - Importance level (true for critical items, false for optional)
        - Frequency (daily, weekly, as_needed)

        Return ONLY a valid JSON array with this exact structure:
        [
          {
            "id": "unique_identifier",
            "task": "Clear actionable task description",
            "category": "health|nutrition|exercise|emotional|preparation|self-care",
            "week": ${currentWeek},
            "trimester": ${trimester},
            "frequency": "daily|weekly|as_needed",
            "important": true|false,
            "personalized": true
          }
        ]

        Make the tasks specific, helpful, and encouraging. Consider the user's profile when suggesting activities.
      `;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      
      // Extract JSON from markdown code blocks if present
      let jsonText = text;
      const jsonMatch = text.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
      if (jsonMatch) {
        jsonText = jsonMatch[1];
      }
      
      // Parse the JSON response
      const checklistData = JSON.parse(jsonText);
      
      // Convert to DailyChecklist objects
      const checklist = checklistData.map(item => new DailyChecklist({
        ...item,
        generatedAt: date
      }));

      return checklist;
    } catch (error) {
      console.error('Error generating dynamic checklist:', error);
      // Fallback to static checklist if AI fails
      return this.getChecklistForWeek(this.calculateCurrentWeek(pregnancy.lastMenstrualPeriod));
    }
  }

  static getChecklistForWeek(week) {
    const trimester = this.getTrimester(week);
    const allTasks = this.getAllTasks();
    
    return allTasks.filter(task => 
      task.week === week || 
      task.trimester === trimester || 
      task.frequency === 'daily'
    );
  }

  static getTrimester(week) {
    if (week <= 12) return 1;
    if (week <= 26) return 2;
    return 3;
  }

  static getAllTasks() {
    return [
      // Daily tasks (all weeks)
      new DailyChecklist({
        id: 'daily_vitamins',
        task: 'Take prenatal vitamins',
        category: 'health',
        week: null,
        trimester: null,
        frequency: 'daily',
        important: true
      }),
      new DailyChecklist({
        id: 'daily_water',
        task: 'Drink 8-10 glasses of water',
        category: 'nutrition',
        week: null,
        trimester: null,
        frequency: 'daily',
        important: true
      }),
      new DailyChecklist({
        id: 'daily_rest',
        task: 'Get adequate rest (7-9 hours)',
        category: 'health',
        week: null,
        trimester: null,
        frequency: 'daily'
      }),
      new DailyChecklist({
        id: 'daily_gentle_exercise',
        task: 'Do gentle exercise or walking',
        category: 'exercise',
        week: null,
        trimester: null,
        frequency: 'daily'
      }),

      // First Trimester specific
      new DailyChecklist({
        id: 'first_manage_nausea',
        task: 'Manage morning sickness with small meals',
        category: 'health',
        week: 6,
        trimester: 1,
        frequency: 'daily',
        important: true
      }),
      new DailyChecklist({
        id: 'first_avoid_harmful',
        task: 'Avoid alcohol, smoking, and harmful substances',
        category: 'health',
        week: 4,
        trimester: 1,
        frequency: 'daily',
        important: true
      }),

      // Second Trimester specific
      new DailyChecklist({
        id: 'second_healthy_diet',
        task: 'Eat a balanced diet with extra protein',
        category: 'nutrition',
        week: 14,
        trimester: 2,
        frequency: 'daily'
      }),
      new DailyChecklist({
        id: 'second_prenatal_yoga',
        task: 'Practice prenatal yoga or stretching',
        category: 'exercise',
        week: 16,
        trimester: 2,
        frequency: 'daily'
      }),
      new DailyChecklist({
        id: 'second_bond_with_baby',
        task: 'Talk to your baby and feel for movements',
        category: 'emotional',
        week: 18,
        trimester: 2,
        frequency: 'daily'
      }),

      // Third Trimester specific
      new DailyChecklist({
        id: 'third_kegels',
        task: 'Practice Kegel exercises',
        category: 'exercise',
        week: 28,
        trimester: 3,
        frequency: 'daily'
      }),
      new DailyChecklist({
        id: 'third_monitor_movements',
        task: 'Count baby kicks and movements',
        category: 'health',
        week: 28,
        trimester: 3,
        frequency: 'daily',
        important: true
      }),
      new DailyChecklist({
        id: 'third_prepare_bag',
        task: 'Pack hospital bag (if not done)',
        category: 'preparation',
        week: 32,
        trimester: 3,
        frequency: 'weekly'
      }),
      new DailyChecklist({
        id: 'third_birth_plan',
        task: 'Review and finalize birth plan',
        category: 'preparation',
        week: 34,
        trimester: 3,
        frequency: 'weekly'
      }),

      // Weekly tasks
      new DailyChecklist({
        id: 'weekly_weight_check',
        task: 'Check weight gain (if recommended by doctor)',
        category: 'health',
        week: 8,
        trimester: 1,
        frequency: 'weekly'
      }),
      new DailyChecklist({
        id: 'weekly_meal_planning',
        task: 'Plan healthy meals for the week',
        category: 'nutrition',
        week: 12,
        trimester: 1,
        frequency: 'weekly'
      }),
      new DailyChecklist({
        id: 'weekly_baby_shopping',
        task: 'Research and shop for baby essentials',
        category: 'preparation',
        week: 20,
        trimester: 2,
        frequency: 'weekly'
      }),
      new DailyChecklist({
        id: 'weekly_nursery_prep',
        task: 'Prepare nursery or baby space',
        category: 'preparation',
        week: 30,
        trimester: 3,
        frequency: 'weekly'
      })
    ];
  }

  static getTasksByCategory(week) {
    const tasks = this.getChecklistForWeek(week);
    const categories = {};
    
    tasks.forEach(task => {
      if (!categories[task.category]) {
        categories[task.category] = [];
      }
      categories[task.category].push(task);
    });
    
    return categories;
  }

  toJSON() {
    return {
      id: this.id,
      task: this.task,
      category: this.category,
      week: this.week,
      trimester: this.trimester,
      frequency: this.frequency,
      important: this.important,
      personalized: this.personalized,
      generatedAt: this.generatedAt
    };
  }

  // Helper method to calculate current pregnancy week
  static calculateCurrentWeek(lastMenstrualPeriod) {
    if (!lastMenstrualPeriod) return null;
    
    const lmp = new Date(lastMenstrualPeriod);
    const today = new Date();
    const diffTime = today - lmp;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    return Math.floor(diffDays / 7);
  }

  // Helper method to calculate days until due date
  static calculateDaysUntilDueDate(dueDate) {
    if (!dueDate) return null;
    
    const due = new Date(dueDate);
    const today = new Date();
    const diffTime = due - today;
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
}

module.exports = DailyChecklist;

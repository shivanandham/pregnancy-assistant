class PregnancyMilestone {
  constructor(data) {
    this.week = data.week;
    this.title = data.title;
    this.description = data.description;
    this.category = data.category;
    this.important = data.important || false;
  }

  static getMilestones() {
    return [
      // First Trimester (Weeks 1-12)
      new PregnancyMilestone({
        week: 4,
        title: "Positive Pregnancy Test",
        description: "Your pregnancy test shows positive! The fertilized egg has implanted in your uterus.",
        category: "confirmation",
        important: true
      }),
      new PregnancyMilestone({
        week: 5,
        title: "Heart Begins to Beat",
        description: "Your baby's heart starts beating! It's about the size of a sesame seed.",
        category: "development",
        important: true
      }),
      new PregnancyMilestone({
        week: 6,
        title: "Brain Development Begins",
        description: "Your baby's brain and nervous system are forming rapidly.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 8,
        title: "First Ultrasound",
        description: "You can see your baby's heartbeat on ultrasound! Baby is about the size of a raspberry.",
        category: "medical",
        important: true
      }),
      new PregnancyMilestone({
        week: 10,
        title: "Organs Forming",
        description: "All major organs are forming. Baby is about the size of a strawberry.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 12,
        title: "End of First Trimester",
        description: "Risk of miscarriage significantly decreases. Baby is about the size of a lime.",
        category: "milestone",
        important: true
      }),

      // Second Trimester (Weeks 13-26)
      new PregnancyMilestone({
        week: 14,
        title: "Gender Reveal Possible",
        description: "You might be able to find out your baby's gender through ultrasound.",
        category: "milestone"
      }),
      new PregnancyMilestone({
        week: 16,
        title: "Feeling Baby Move",
        description: "You might start feeling your baby's first movements (quickening).",
        category: "milestone",
        important: true
      }),
      new PregnancyMilestone({
        week: 18,
        title: "Anatomy Scan",
        description: "Detailed ultrasound to check baby's development and anatomy.",
        category: "medical",
        important: true
      }),
      new PregnancyMilestone({
        week: 20,
        title: "Halfway Point",
        description: "You're halfway through your pregnancy! Baby is about the size of a banana.",
        category: "milestone",
        important: true
      }),
      new PregnancyMilestone({
        week: 22,
        title: "Hair and Eyebrows",
        description: "Your baby's hair and eyebrows are starting to grow.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 24,
        title: "Viability Milestone",
        description: "Your baby has a chance of survival if born early (with medical care).",
        category: "milestone",
        important: true
      }),

      // Third Trimester (Weeks 27-40)
      new PregnancyMilestone({
        week: 28,
        title: "Third Trimester Begins",
        description: "Welcome to the final trimester! Baby is about the size of an eggplant.",
        category: "milestone",
        important: true
      }),
      new PregnancyMilestone({
        week: 30,
        title: "Baby's Eyes Open",
        description: "Your baby can now open and close their eyes.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 32,
        title: "Head Down Position",
        description: "Your baby is likely moving into the head-down position for birth.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 34,
        title: "Lung Development",
        description: "Your baby's lungs are almost fully developed.",
        category: "development"
      }),
      new PregnancyMilestone({
        week: 36,
        title: "Full Term",
        description: "Your baby is considered full-term and ready for birth!",
        category: "milestone",
        important: true
      }),
      new PregnancyMilestone({
        week: 38,
        title: "Any Day Now",
        description: "Your baby could arrive at any time. Pack your hospital bag!",
        category: "preparation",
        important: true
      }),
      new PregnancyMilestone({
        week: 40,
        title: "Due Date",
        description: "Your estimated due date has arrived. Most babies are born within 2 weeks of this date.",
        category: "milestone",
        important: true
      })
    ];
  }

  static getMilestonesForWeek(week) {
    const allMilestones = this.getMilestones();
    return allMilestones.filter(milestone => milestone.week === week);
  }

  static getUpcomingMilestones(currentWeek, limit = 3) {
    const allMilestones = this.getMilestones();
    return allMilestones
      .filter(milestone => milestone.week > currentWeek)
      .slice(0, limit);
  }

  static getRecentMilestones(currentWeek, limit = 3) {
    const allMilestones = this.getMilestones();
    return allMilestones
      .filter(milestone => milestone.week <= currentWeek)
      .slice(-limit);
  }

  toJSON() {
    return {
      week: this.week,
      title: this.title,
      description: this.description,
      category: this.category,
      important: this.important
    };
  }
}

module.exports = PregnancyMilestone;

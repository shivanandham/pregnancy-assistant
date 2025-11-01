const prisma = require('../lib/prisma');

class WeeklyContent {
  constructor(data) {
    this.id = data.id;
    this.userId = data.userId;
    this.week = data.week;
    this.title = data.title;
    this.highlights = data.highlights;
    this.facts = data.facts;
    this.thingsToDo = data.thingsToDo;
    this.content = data.content;
    this.createdAt = data.createdAt;
    this.expiresAt = data.expiresAt;
  }

  static async getContentForWeek(userId, week) {
    // Check if we have content for this week that hasn't expired
    const now = new Date();
    const existingContent = await prisma.weeklyContent.findUnique({
      where: {
        userId_week: {
          userId: userId,
          week: week
        }
      }
    });

    // If we have cached content that hasn't expired, return it
    if (existingContent && existingContent.expiresAt > now) {
      return new WeeklyContent(existingContent);
    }

    // If no cached content exists or it's expired, generate new content with Gemini
    try {
      return await this.generateContentForWeek(userId, week);
    } catch (error) {
      console.error(`Failed to generate weekly content for week ${week}:`, error);
      // Return null if generation fails
      return null;
    }
  }

  static async generateContentForWeek(userId, week) {
    const { GoogleGenerativeAI } = require('@google/generative-ai');
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

    try {
      // Determine trimester from week
      const trimester = week <= 12 ? 1 : week <= 26 ? 2 : 3;

      const prompt = `Generate personalized weekly content for pregnancy week ${week} (Trimester ${trimester}). 

Return ONLY a valid JSON object with this exact structure:
{
  "title": "Week ${week} Overview",
  "highlights": [
    "Key highlight or milestone for this week",
    "Important development happening",
    "Noteworthy fact about this week"
  ],
  "facts": [
    "Interesting fact about baby development in week ${week}",
    "Fact about mother's body changes",
    "General pregnancy fact relevant to this week"
  ],
  "thingsToDo": [
    "Actionable item specific to week ${week}",
    "Something to consider or prepare for",
    "Activity or task relevant to this stage"
  ]
}

Make the content specific to week ${week} of pregnancy. Focus on:
- Baby development milestones
- Physical changes and symptoms to expect
- Things to do or prepare
- Interesting facts about this stage

Keep each array item concise (1-2 sentences max). Make it informative and encouraging.`;

      const result = await model.generateContent(prompt);
      const response = await result.response;
      const text = response.text();
      
      // Clean the response text (remove markdown formatting if present)
      const cleanText = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      
      // Parse the JSON response
      const contentData = JSON.parse(cleanText);

      // Calculate expiration (end of the current week - Sunday at 11:59 PM)
      // Week starts on Monday (day 1), ends on Sunday (day 0)
      const now = new Date();
      const expiresAt = new Date(now);
      const daysUntilSunday = (7 - expiresAt.getDay()) % 7 || 7; // Days until next Sunday
      expiresAt.setDate(expiresAt.getDate() + daysUntilSunday);
      expiresAt.setHours(23, 59, 59, 999); // End of Sunday

      // Save content to database
      const saved = await prisma.weeklyContent.upsert({
        where: {
          userId_week: {
            userId: userId,
            week: week
          }
        },
        update: {
          title: contentData.title || null,
          highlights: contentData.highlights || [],
          facts: contentData.facts || [],
          thingsToDo: contentData.thingsToDo || [],
          content: contentData,
          expiresAt: expiresAt
        },
        create: {
          userId: userId,
          week: week,
          title: contentData.title || null,
          highlights: contentData.highlights || [],
          facts: contentData.facts || [],
          thingsToDo: contentData.thingsToDo || [],
          content: contentData,
          expiresAt: expiresAt
        }
      });

      console.log(`Successfully generated weekly content for week ${week}`);
      return new WeeklyContent(saved);
    } catch (error) {
      console.error('Error generating weekly content with Gemini:', error);
      throw error;
    }
  }

  toJSON() {
    return {
      id: this.id,
      userId: this.userId,
      week: this.week,
      title: this.title,
      highlights: this.highlights,
      facts: this.facts,
      thingsToDo: this.thingsToDo,
      content: this.content,
      createdAt: this.createdAt,
      expiresAt: this.expiresAt
    };
  }
}

module.exports = WeeklyContent;


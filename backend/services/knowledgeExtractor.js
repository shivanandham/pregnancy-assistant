const { GoogleGenerativeAI } = require('@google/generative-ai');
const KnowledgeFact = require('../models/KnowledgeFact');
const ConversationChunk = require('../models/ConversationChunk');

class KnowledgeExtractor {
  static async extractKnowledge(userMessage, aiResponse, currentWeek) {
    try {
      // Extract keywords from the conversation
      const keywords = KnowledgeExtractor.extractKeywords(userMessage + ' ' + aiResponse);
      
      // Save conversation chunk
      const conversationChunk = new ConversationChunk({
        content: `User: ${userMessage}\n\nAssistant: ${aiResponse}`,
        weekNumber: currentWeek,
        keywords: keywords.join(', ')
      });
      await conversationChunk.save();

      // Use Gemini to extract structured facts
      const facts = await KnowledgeExtractor.extractFactsWithAI(userMessage, aiResponse, currentWeek);
      
      // Save each extracted fact
      const savedFacts = [];
      for (const fact of facts) {
        const knowledgeFact = new KnowledgeFact({
          category: fact.category,
          factText: fact.fact_text,
          weekNumber: currentWeek,
          metadata: {
            extractedFrom: 'chat',
            confidence: fact.confidence || 'medium'
          }
        });
        
        await knowledgeFact.save();
        savedFacts.push(knowledgeFact);
      }

      console.log(`Extracted ${savedFacts.length} facts from conversation`);
      return {
        conversationChunk,
        facts: savedFacts
      };

    } catch (error) {
      console.error('Error extracting knowledge:', error);
      // Still save conversation chunk even if fact extraction fails
      const conversationChunk = new ConversationChunk({
        content: `User: ${userMessage}\n\nAssistant: ${aiResponse}`,
        weekNumber: currentWeek,
        keywords: KnowledgeExtractor.extractKeywords(userMessage).join(', ')
      });
      await conversationChunk.save();
      
      return {
        conversationChunk,
        facts: []
      };
    }
  }

  static async extractFactsWithAI(userMessage, aiResponse, currentWeek) {
    try {
      // Check if API key is available
      if (!process.env.GEMINI_API_KEY) {
        console.log('GEMINI_API_KEY not found, skipping AI fact extraction');
        return [];
      }

      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      const extractionPrompt = `
Extract structured pregnancy-related facts from this conversation.
Return a JSON array of facts with category and fact_text.

Categories: symptom, milestone, preference, medical, activity

User: ${userMessage}
Assistant: ${aiResponse}

Return format (JSON only, no other text):
[
  {"category": "symptom", "fact_text": "User experiencing morning sickness at week ${currentWeek || 'unknown'}"},
  {"category": "preference", "fact_text": "User prefers natural birth options"}
]

Only extract facts that are explicitly mentioned or clearly implied. Be conservative - if unsure, don't extract.
`;

      console.log('Attempting AI fact extraction...');
      const result = await model.generateContent(extractionPrompt);
      const response = result.response.text();
      
      console.log('AI extraction response:', response);
      
      // Clean the response to extract JSON
      const jsonMatch = response.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        console.log('No JSON found in AI response:', response);
        return [];
      }

      const facts = JSON.parse(jsonMatch[0]);
      console.log('Parsed facts:', facts);
      
      // Validate and clean facts
      const validFacts = facts.filter(fact => 
        fact.category && 
        fact.fact_text && 
        ['symptom', 'milestone', 'preference', 'medical', 'activity'].includes(fact.category)
      );
      
      console.log('Valid facts:', validFacts);
      return validFacts;

    } catch (error) {
      console.error('Error in AI fact extraction:', error);
      return [];
    }
  }

  static extractKeywords(text) {
    // Simple keyword extraction - remove common words and extract meaningful terms
    const commonWords = new Set([
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by',
      'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did',
      'will', 'would', 'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these', 'those',
      'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them'
    ]);

    const words = text.toLowerCase()
      .replace(/[^\w\s]/g, ' ')
      .split(/\s+/)
      .filter(word => word.length > 2 && !commonWords.has(word));

    // Get unique words and limit to top 10
    const uniqueWords = [...new Set(words)].slice(0, 10);
    
    return uniqueWords;
  }

  static async getExtractionStats() {
    try {
      const facts = await KnowledgeFact.getAll();
      const chunks = await ConversationChunk.getAll();
      
      const stats = {
        totalFacts: facts.length,
        totalConversations: chunks.length,
        factsByCategory: {},
        recentActivity: {
          factsLast7Days: 0,
          conversationsLast7Days: 0
        }
      };

      // Count facts by category
      facts.forEach(fact => {
        stats.factsByCategory[fact.category] = (stats.factsByCategory[fact.category] || 0) + 1;
      });

      // Count recent activity (last 7 days)
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();
      
      stats.recentActivity.factsLast7Days = facts.filter(fact => 
        new Date(fact.createdAt) > sevenDaysAgo
      ).length;
      
      stats.recentActivity.conversationsLast7Days = chunks.filter(chunk => 
        new Date(chunk.createdAt) > sevenDaysAgo
      ).length;

      return stats;
    } catch (error) {
      console.error('Error getting extraction stats:', error);
      return null;
    }
  }
}

module.exports = KnowledgeExtractor;

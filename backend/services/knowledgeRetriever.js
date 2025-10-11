const KnowledgeFact = require('../models/KnowledgeFact');
const ConversationChunk = require('../models/ConversationChunk');

class KnowledgeRetriever {
  static async getRelevantContext(userMessage, currentWeek, limit = 10) {
    try {
      // Extract keywords from user message
      const keywords = KnowledgeRetriever.extractKeywords(userMessage);
      
      // Search for relevant facts
      const relevantFacts = await KnowledgeRetriever.searchRelevantFacts(keywords, currentWeek, limit);
      
      // Search for relevant conversation chunks
      const relevantConversations = await KnowledgeRetriever.searchRelevantConversations(keywords, currentWeek, Math.floor(limit / 2));
      
      // Format context for AI
      const formattedContext = KnowledgeRetriever.formatContext(relevantFacts, relevantConversations, currentWeek);
      
      return {
        relevantFacts,
        relevantConversations,
        formattedContext,
        keywords
      };

    } catch (error) {
      console.error('Error retrieving relevant context:', error);
      return {
        relevantFacts: [],
        relevantConversations: [],
        formattedContext: '',
        keywords: []
      };
    }
  }

  static async searchRelevantFacts(keywords, currentWeek, limit) {
    try {
      // Build search query from keywords
      const searchQuery = keywords.join(' OR ');
      
      // Search using FTS
      const facts = await KnowledgeFact.search(searchQuery, limit);
      
      // If no results from FTS, try category-based search
      if (facts.length === 0) {
        const categoryFacts = await KnowledgeRetriever.searchByCategory(keywords);
        return categoryFacts.slice(0, limit);
      }
      
      // Prioritize facts from current week or nearby weeks
      const prioritizedFacts = KnowledgeRetriever.prioritizeByWeek(facts, currentWeek);
      
      return prioritizedFacts.slice(0, limit);

    } catch (error) {
      console.error('Error searching relevant facts:', error);
      return [];
    }
  }

  static async searchRelevantConversations(keywords, currentWeek, limit) {
    try {
      // Build search query from keywords
      const searchQuery = keywords.join(' OR ');
      
      // Search using FTS
      const conversations = await ConversationChunk.search(searchQuery, limit);
      
      // If no results, get recent conversations
      if (conversations.length === 0) {
        return await ConversationChunk.getRecent(limit);
      }
      
      // Prioritize conversations from current week or nearby weeks
      const prioritizedConversations = KnowledgeRetriever.prioritizeByWeek(conversations, currentWeek);
      
      return prioritizedConversations.slice(0, limit);

    } catch (error) {
      console.error('Error searching relevant conversations:', error);
      return [];
    }
  }

  static async searchByCategory(keywords) {
    const categories = ['symptom', 'milestone', 'preference', 'medical', 'activity'];
    const relevantCategories = [];
    
    // Map keywords to categories
    keywords.forEach(keyword => {
      if (keyword.includes('symptom') || keyword.includes('pain') || keyword.includes('nausea') || keyword.includes('tired')) {
        relevantCategories.push('symptom');
      }
      if (keyword.includes('milestone') || keyword.includes('week') || keyword.includes('month')) {
        relevantCategories.push('milestone');
      }
      if (keyword.includes('prefer') || keyword.includes('like') || keyword.includes('want')) {
        relevantCategories.push('preference');
      }
      if (keyword.includes('doctor') || keyword.includes('medical') || keyword.includes('health')) {
        relevantCategories.push('medical');
      }
      if (keyword.includes('exercise') || keyword.includes('activity') || keyword.includes('walk')) {
        relevantCategories.push('activity');
      }
    });

    // Get facts from relevant categories
    const allFacts = [];
    for (const category of [...new Set(relevantCategories)]) {
      const facts = await KnowledgeFact.getByCategory(category, 5);
      allFacts.push(...facts);
    }

    return allFacts;
  }

  static prioritizeByWeek(items, currentWeek) {
    if (!currentWeek) return items;
    
    return items.sort((a, b) => {
      const aWeek = a.weekNumber || 0;
      const bWeek = b.weekNumber || 0;
      
      // Prioritize current week, then nearby weeks
      const aDistance = Math.abs(aWeek - currentWeek);
      const bDistance = Math.abs(bWeek - currentWeek);
      
      if (aDistance !== bDistance) {
        return aDistance - bDistance;
      }
      
      // If same distance, prioritize by recency
      return new Date(b.createdAt || b.timestamp) - new Date(a.createdAt || a.timestamp);
    });
  }

  static extractKeywords(text) {
    // Simple keyword extraction
    const commonWords = new Set([
      'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by',
      'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'do', 'does', 'did',
      'will', 'would', 'could', 'should', 'may', 'might', 'can', 'this', 'that', 'these', 'those',
      'i', 'you', 'he', 'she', 'it', 'we', 'they', 'me', 'him', 'her', 'us', 'them', 'my', 'your',
      'what', 'how', 'when', 'where', 'why', 'who', 'which'
    ]);

    const words = text.toLowerCase()
      .replace(/[^\w\s]/g, ' ')
      .split(/\s+/)
      .filter(word => word.length > 2 && !commonWords.has(word));

    // Get unique words and limit to top 8
    const uniqueWords = [...new Set(words)].slice(0, 8);
    
    return uniqueWords;
  }

  static formatContext(facts, conversations, currentWeek) {
    let context = '';
    
    if (facts.length > 0) {
      context += 'RELEVANT FACTS FROM PREVIOUS CONVERSATIONS:\n';
      facts.forEach((fact, index) => {
        const weekInfo = fact.weekNumber ? ` (Week ${fact.weekNumber})` : '';
        context += `${index + 1}. [${fact.category.toUpperCase()}]${weekInfo}: ${fact.factText}\n`;
      });
      context += '\n';
    }
    
    if (conversations.length > 0) {
      context += 'RELEVANT PREVIOUS CONVERSATIONS:\n';
      conversations.slice(0, 3).forEach((conversation, index) => {
        const weekInfo = conversation.weekNumber ? ` (Week ${conversation.weekNumber})` : '';
        const preview = conversation.content.length > 200 
          ? conversation.content.substring(0, 200) + '...'
          : conversation.content;
        context += `${index + 1}.${weekInfo} ${preview}\n\n`;
      });
    }
    
    if (context) {
      context += 'Use this information to provide more personalized and contextually relevant responses.\n';
    }
    
    return context;
  }

  static async getKnowledgeTimeline(weeks = null) {
    try {
      let facts, conversations;
      
      if (weeks && weeks.start && weeks.end) {
        facts = await KnowledgeFact.getByWeekRange(weeks.start, weeks.end);
        conversations = await ConversationChunk.getByWeekRange(weeks.start, weeks.end);
      } else {
        facts = await KnowledgeFact.getAll();
        conversations = await ConversationChunk.getAll();
      }
      
      // Combine and sort by date
      const timeline = [];
      
      facts.forEach(fact => {
        timeline.push({
          type: 'fact',
          data: fact,
          date: fact.dateRecorded,
          week: fact.weekNumber
        });
      });
      
      conversations.forEach(conversation => {
        timeline.push({
          type: 'conversation',
          data: conversation,
          date: conversation.timestamp,
          week: conversation.weekNumber
        });
      });
      
      // Sort by date
      timeline.sort((a, b) => new Date(a.date) - new Date(b.date));
      
      return timeline;

    } catch (error) {
      console.error('Error getting knowledge timeline:', error);
      return [];
    }
  }
}

module.exports = KnowledgeRetriever;

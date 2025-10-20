const { GoogleGenerativeAI } = require('@google/generative-ai');
const prisma = require('../lib/prisma');
const fs = require('fs');
const path = require('path');
const ChatMessage = require('../models/ChatMessage');
const ChatSession = require('../models/ChatSession');
const Pregnancy = require('../models/Pregnancy');

class ChatController {
  // Load pregnancy do's and don'ts guide
  static loadPregnancyGuide() {
    try {
      const guidePath = path.join(__dirname, '../data/pregnancy-dos-donts.txt');
      return fs.readFileSync(guidePath, 'utf8');
    } catch (error) {
      console.error('Error loading pregnancy guide:', error);
      return '';
    }
  }

  // Calculate current pregnancy week
  static calculateCurrentWeek(lastMenstrualPeriod) {
    if (!lastMenstrualPeriod) return null;
    
    const lmp = new Date(lastMenstrualPeriod);
    const today = new Date();
    const diffTime = today - lmp;
    const diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24));
    const currentWeek = Math.floor(diffDays / 7);
    
    return Math.max(0, currentWeek);
  }

  // Generate a chat title from the first message
  static generateChatTitle(message) {
    // Clean and truncate the message
    let title = message.trim();
    
    // Remove common greetings and make it more concise
    const greetings = ['hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening'];
    const lowerMessage = title.toLowerCase();
    
    for (const greeting of greetings) {
      if (lowerMessage.startsWith(greeting)) {
        title = title.substring(greeting.length).trim();
        break;
      }
    }
    
    // If title is empty after removing greetings, use the original message
    if (title.length === 0) {
      title = message.trim();
    }
    
    // Capitalize first letter
    if (title.length > 0) {
      title = title.charAt(0).toUpperCase() + title.slice(1);
    }
    
    // Truncate to reasonable length (max 50 characters)
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }
    
    // If title is still empty or too short, use a default
    if (title.length < 2) {
      title = 'New Chat';
    }
    
    return title;
  }

  // Pregnancy-specific context to enhance AI responses
  static getPregnancyContext(week = null) {
    let context = `
You are a helpful pregnancy assistant AI. You provide supportive, evidence-based information about pregnancy, but always remind users to consult with their healthcare provider for medical advice. 

Key guidelines:
- Be encouraging and supportive
- Provide practical, evidence-based information
- Always include disclaimers about consulting healthcare providers
- Focus on common pregnancy topics: nutrition, exercise, symptoms, preparation, milestones
- Be sensitive to concerns and anxieties
- Provide week-by-week information when relevant
- Suggest tracking and monitoring when appropriate

Remember: You are not a replacement for medical care, but a supportive companion.

PREGNANCY DO'S AND DON'TS GUIDE:
${ChatController.loadPregnancyGuide()}
`;

    if (week) {
      context += `\n\nThe user is currently at week ${week} of pregnancy.`;
    }

    return context;
  }

  // Send chat message
  static async sendMessage(req, res) {
    try {
      const userId = req.dbUser.id;
      const { message, context, sessionId } = req.body;
      
      if (!message) {
        return res.status(400).json({
          success: false,
          message: 'Message is required'
        });
      }

      // Ensure we have a valid session
      let validSessionId = sessionId;
      
      if (validSessionId) {
        // Verify the session exists and belongs to user
        const session = await prisma.chatSession.findFirst({
          where: { 
            id: validSessionId,
            userId 
          }
        });
        if (!session) {
          // Session doesn't exist or doesn't belong to user, create a new one
          const newSession = await prisma.chatSession.create({
            data: {
              userId,
              title: 'New Chat',
              isActive: true
            }
          });
          validSessionId = newSession.id;
        }
      } else {
        // No session provided, get or create active session
        let activeSession = await prisma.chatSession.findFirst({
          where: { 
            userId,
            isActive: true 
          }
        });
        if (!activeSession) {
          activeSession = await prisma.chatSession.create({
            data: {
              userId,
              title: 'New Chat',
              isActive: true
            }
          });
        }
        validSessionId = activeSession.id;
      }

      // Save user message
      const userMessage = await prisma.chatMessage.create({
        data: {
          content: message,
          type: 'user',
          context,
          sessionId: validSessionId
        }
      });

      // Update message count for the session (user message)
      await prisma.chatSession.update({
        where: { id: validSessionId },
        data: {
          messageCount: {
            increment: 1
          }
        }
      });

      // Auto-generate title for new sessions (if this is the first message)
      const session = await prisma.chatSession.findUnique({
        where: { id: validSessionId }
      });
      if (session && session.title === 'New Chat') {
        const generatedTitle = ChatController.generateChatTitle(message);
        console.log(`Updating session title from "${session.title}" to "${generatedTitle}"`);
        await prisma.chatSession.update({
          where: { id: validSessionId },
          data: { title: generatedTitle }
        });
      }

      // Get current pregnancy data for context
      const pregnancy = await prisma.pregnancyData.findUnique({
        where: { userId }
      });
      const currentWeek = pregnancy ? ChatController.calculateCurrentWeek(pregnancy.lastMenstrualPeriod) : null;

      // Retrieve relevant knowledge from previous conversations
      const knowledgeRetriever = require('../services/knowledgeRetriever');
      const relevantContext = await knowledgeRetriever.getRelevantContext(
        message, 
        currentWeek
      );

      // Get user profile context
      const userProfile = await prisma.userProfile.findUnique({
        where: { userId }
      });
      let profileContext = '';
      if (userProfile) {
        const basicInfo = `Age: ${userProfile.age} years, Height: ${userProfile.height} cm, Weight: ${userProfile.weight} kg`;
        const medicalContext = `Medical history: ${JSON.stringify(userProfile.medicalHistory)}, Allergies: ${JSON.stringify(userProfile.allergies)}`;
        profileContext = `\n\nUser Profile Information:
- Basic Info: ${basicInfo}
- Medical Context: ${medicalContext}`;
      }

      // Build context-aware prompt with current time
      const currentTime = new Date();
      let timeContext = `Current date and time: ${currentTime.toLocaleString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        timeZoneName: 'short'
      })}`;
      
      // Add user's timezone if available
      if (userProfile && userProfile.timezone) {
        timeContext += `\nUser's timezone: ${userProfile.timezone}`;
      }
      
      let systemPrompt = ChatController.getPregnancyContext(currentWeek);
      systemPrompt += `\n\n${timeContext}`;
      systemPrompt += profileContext;
      
      if (context) {
        systemPrompt += `\n\nAdditional context: ${context}`;
      }
      
      // Enhance system prompt with RAG context
      if (relevantContext.formattedContext) {
        systemPrompt += `\n\n${relevantContext.formattedContext}`;
      }

      // Initialize Gemini AI
      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      // Check if we should ask diagnostic questions first
      const diagnosticQuestioner = require('../services/diagnosticQuestioner');
      const chatHistory = await ChatMessage.getAll();
      
      const diagnosticAnalysis = await diagnosticQuestioner.analyzeAndQuestion(
        message, 
        currentWeek, 
        chatHistory
      );

      let aiResponse;
      let diagnosticMessage = null;

      if (diagnosticAnalysis.shouldAskQuestions && diagnosticAnalysis.questions.length > 0) {
        // Ask diagnostic questions first
        aiResponse = diagnosticQuestioner.formatQuestionsForDisplay(diagnosticAnalysis.questions);
        
        // Save diagnostic question message
        diagnosticMessage = new ChatMessage({
          content: aiResponse,
          type: 'assistant',
          context: currentWeek ? `Week ${currentWeek}` : null,
          isDiagnostic: true,
          diagnosticQuestions: diagnosticAnalysis.questions,
          parentMessageId: userMessage.id,
          sessionId: validSessionId
        });
        await diagnosticMessage.save();
        
      } else {
        // Provide direct response
        const fullPrompt = `${systemPrompt}\n\nUser question: ${message}`;
        const result = await model.generateContent(fullPrompt);
        aiResponse = result.response.text();
      }

      // Save AI response (only if not already saved as diagnostic message)
      let assistantMessage;
      if (!diagnosticMessage) {
        assistantMessage = await prisma.chatMessage.create({
          data: {
            content: aiResponse,
            type: 'assistant',
            context: currentWeek ? `Week ${currentWeek}` : null,
            sessionId: validSessionId
          }
        });
      } else {
        assistantMessage = diagnosticMessage;
      }

      // Update message count for the session (assistant message)
      await prisma.chatSession.update({
        where: { id: validSessionId },
        data: {
          messageCount: {
            increment: 1
          }
        }
      });

      // Extract and store knowledge asynchronously
      const knowledgeExtractor = require('../services/knowledgeExtractor');
      knowledgeExtractor.extractKnowledge(message, aiResponse, currentWeek)
        .catch(err => console.error('Knowledge extraction error:', err));

      // Extract and create symptoms asynchronously
      const symptomExtractor = require('../services/symptomExtractor');
      symptomExtractor.extractAndCreateSymptoms(message, aiResponse, currentWeek, userId)
        .then(symptoms => {
          if (symptoms.length > 0) {
            console.log(`Created ${symptoms.length} symptoms from chat conversation`);
          }
        })
        .catch(err => console.error('Symptom extraction error:', err));

      res.json({
        success: true,
        data: {
          userMessage: userMessage,
          assistantMessage: assistantMessage.toJSON ? assistantMessage.toJSON() : assistantMessage
        }
      });

    } catch (error) {
      console.error('Error in chat:', error);
      
      // Try to get a valid session for error message
      let errorSessionId = null;
      try {
        let activeSession = await ChatSession.getActive();
        if (!activeSession) {
          activeSession = await ChatSession.createNew();
        }
        errorSessionId = activeSession.id;
      } catch (sessionError) {
        console.error('Error getting session for error message:', sessionError);
      }
      
      // Save error message
      const errorMessage = new ChatMessage({
        content: 'Sorry, I encountered an error. Please try again later.',
        type: 'assistant',
        isError: true,
        sessionId: errorSessionId
      });
      await errorMessage.save();
      
      res.status(500).json({
        success: false,
        message: 'Failed to get AI response',
        data: {
          errorMessage: errorMessage.toJSON()
        }
      });
    }
  }

  // Get chat history
  static async getHistory(req, res) {
    try {
      const { limit = 50 } = req.query;
      const messages = await ChatMessage.getRecent(parseInt(limit));
      
      res.json({
        success: true,
        data: messages.map(message => message.toJSON())
      });
    } catch (error) {
      console.error('Error getting chat history:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Clear chat history
  static async clearHistory(req, res) {
    try {
      await ChatMessage.clearHistory();
      
      res.json({
        success: true,
        message: 'Chat history cleared successfully'
      });
    } catch (error) {
      console.error('Error clearing chat history:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Get message by ID
  static async getMessageById(req, res) {
    try {
      const { id } = req.params;
      const message = await ChatMessage.getById(id);
      
      if (!message) {
        return res.status(404).json({
          success: false,
          message: 'Message not found'
        });
      }
      
      res.json({
        success: true,
        data: message.toJSON()
      });
    } catch (error) {
      console.error('Error getting message:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Delete message
  static async deleteMessage(req, res) {
    try {
      const { id } = req.params;
      const message = await ChatMessage.getById(id);
      
      if (!message) {
        return res.status(404).json({
          success: false,
          message: 'Message not found'
        });
      }

      await ChatMessage.delete(id);
      
      res.json({
        success: true,
        message: 'Message deleted successfully'
      });
    } catch (error) {
      console.error('Error deleting message:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  // Handle diagnostic answers
  static async answerDiagnosticQuestions(req, res) {
    try {
      const { messageId, answers } = req.body;
      
      if (!messageId || !answers) {
        return res.status(400).json({
          success: false,
          message: 'Message ID and answers are required'
        });
      }

      // Get the original diagnostic message
      const diagnosticMessage = await ChatMessage.getById(messageId);
      if (!diagnosticMessage || !diagnosticMessage.isDiagnostic) {
        return res.status(404).json({
          success: false,
          message: 'Diagnostic message not found'
        });
      }

      // Get pregnancy context
      const pregnancy = await Pregnancy.getCurrent();
      const currentWeek = pregnancy ? pregnancy.getCurrentWeek() : null;

      // Generate follow-up response based on answers
      const diagnosticQuestioner = require('../services/diagnosticQuestioner');
      const followUpResponse = await diagnosticQuestioner.generateFollowUpResponse(
        answers,
        diagnosticMessage.parentMessageId ? 
          (await ChatMessage.getById(diagnosticMessage.parentMessageId)).content : 
          'Original concern',
        currentWeek
      );

      // Save the follow-up response
      const assistantMessage = new ChatMessage({
        content: followUpResponse,
        type: 'assistant',
        context: currentWeek ? `Week ${currentWeek}` : null,
        diagnosticAnswers: answers,
        parentMessageId: messageId,
        sessionId: diagnosticMessage.sessionId
      });
      await assistantMessage.save();

      res.json({
        success: true,
        data: {
          message: assistantMessage.toJSON()
        }
      });

    } catch (error) {
      console.error('Error handling diagnostic answers:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}

module.exports = ChatController;

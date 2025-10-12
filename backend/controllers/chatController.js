const { GoogleGenerativeAI } = require('@google/generative-ai');
const ChatMessage = require('../models/ChatMessage');
const Pregnancy = require('../models/Pregnancy');
const UserProfile = require('../models/UserProfile');
const fs = require('fs');
const path = require('path');

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
    
    // Capitalize first letter
    if (title.length > 0) {
      title = title.charAt(0).toUpperCase() + title.slice(1);
    }
    
    // Truncate to reasonable length (max 50 characters)
    if (title.length > 50) {
      title = title.substring(0, 47) + '...';
    }
    
    // If title is empty or too short, use a default
    if (title.length < 3) {
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
      const { message, context, sessionId } = req.body;
      
      if (!message) {
        return res.status(400).json({
          success: false,
          message: 'Message is required'
        });
      }

      // Save user message
      const userMessage = new ChatMessage({
        content: message,
        type: 'user',
        context,
        sessionId: sessionId
      });
      await userMessage.save();

      // Update message count for the session (user message)
      const ChatSession = require('../models/ChatSession');
      await ChatSession.incrementMessageCount(sessionId);

      // Auto-generate title for new sessions (if this is the first message)
      if (sessionId) {
        const session = await ChatSession.getById(sessionId);
        if (session && session.title === 'New Chat') {
          const generatedTitle = ChatController.generateChatTitle(message);
          await ChatSession.updateTitle(sessionId, generatedTitle);
        }
      }

      // Get current pregnancy data for context
      const pregnancy = await Pregnancy.getCurrent();
      const currentWeek = pregnancy ? pregnancy.getCurrentWeek() : null;

      // Retrieve relevant knowledge from previous conversations
      const knowledgeRetriever = require('../services/knowledgeRetriever');
      const relevantContext = await knowledgeRetriever.getRelevantContext(
        message, 
        currentWeek
      );

      // Get user profile context
      const userProfile = await UserProfile.get();
      let profileContext = '';
      if (userProfile) {
        profileContext = `\n\nUser Profile Information:
- Basic Info: ${userProfile.getFormattedProfile()}
- Medical Context: ${userProfile.getMedicalContext()}`;
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
          sessionId: sessionId
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
        assistantMessage = new ChatMessage({
          content: aiResponse,
          type: 'assistant',
          context: currentWeek ? `Week ${currentWeek}` : null,
          sessionId: sessionId
        });
        await assistantMessage.save();
      } else {
        assistantMessage = diagnosticMessage;
      }

      // Update message count for the session (assistant message)
      await ChatSession.incrementMessageCount(sessionId);

      // Extract and store knowledge asynchronously
      const knowledgeExtractor = require('../services/knowledgeExtractor');
      knowledgeExtractor.extractKnowledge(message, aiResponse, currentWeek)
        .catch(err => console.error('Knowledge extraction error:', err));

      // Extract and create symptoms asynchronously
      const symptomExtractor = require('../services/symptomExtractor');
      symptomExtractor.extractAndCreateSymptoms(message, aiResponse, currentWeek)
        .then(symptoms => {
          if (symptoms.length > 0) {
            console.log(`Created ${symptoms.length} symptoms from chat conversation`);
          }
        })
        .catch(err => console.error('Symptom extraction error:', err));

      res.json({
        success: true,
        data: {
          userMessage: userMessage.toJSON(),
          assistantMessage: assistantMessage.toJSON()
        }
      });

    } catch (error) {
      console.error('Error in chat:', error);
      
      // Save error message
      const errorMessage = new ChatMessage({
        content: 'Sorry, I encountered an error. Please try again later.',
        type: 'assistant',
        isError: true
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
        sessionId: sessionId
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

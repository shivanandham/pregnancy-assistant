const { GoogleGenerativeAI } = require('@google/generative-ai');
const UserProfile = require('../models/UserProfile');

class DiagnosticQuestioner {
  static async analyzeAndQuestion(userMessage, currentWeek, chatHistory = []) {
    try {
      if (!process.env.GEMINI_API_KEY) {
        console.log('GEMINI_API_KEY not found, skipping diagnostic analysis');
        return { shouldAskQuestions: false, questions: [], response: null };
      }

      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      // Build chat history context
      const historyContext = chatHistory.slice(-5).map(msg => 
        `${msg.type === 'user' ? 'User' : 'Assistant'}: ${msg.content}`
      ).join('\n');

      const currentTime = new Date();
      const timeContext = currentTime.toLocaleString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        timeZoneName: 'short'
      });

      // Get user profile context
      const userProfile = await UserProfile.get();
      let profileContext = '';
      if (userProfile) {
        profileContext = `\nUser Profile: ${userProfile.getFormattedProfile()}`;
        const medicalContext = userProfile.getMedicalContext();
        if (medicalContext) {
          profileContext += `\nMedical Context: ${medicalContext}`;
        }
      }

      const diagnosticPrompt = `
You are a pregnancy healthcare assistant. Analyze the user's message and determine if you need to ask follow-up questions before providing advice.

User message: "${userMessage}"
Current pregnancy week: ${currentWeek || 'unknown'}
Current date and time: ${timeContext}${profileContext}
Recent chat history:
${historyContext}

Guidelines:
1. If the user mentions symptoms, concerns, or health issues, ask 2-3 relevant follow-up questions
2. If it's a general question, provide direct helpful information
3. Always prioritize safety - if urgent symptoms, ask key questions first
4. Be empathetic and supportive
5. Ask questions that help you understand severity, duration, triggers, and context

Return a JSON response with this structure:
{
  "shouldAskQuestions": true/false,
  "questions": ["Question 1", "Question 2", "Question 3"],
  "response": "Your initial response or null if asking questions first",
  "urgency": "low/medium/high",
  "category": "symptom/general/emergency/advice"
}

Examples:
- Symptom: "I have a headache" → Ask about duration, severity, triggers
- General: "What should I eat?" → Provide direct advice
- Emergency: "I'm bleeding" → Ask urgent questions first

Return only valid JSON, no other text.
`;

      console.log('Running diagnostic analysis...');
      const result = await model.generateContent(diagnosticPrompt);
      const response = result.response.text();
      
      console.log('Diagnostic response:', response);
      
      // Clean the response to extract JSON
      const jsonMatch = response.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        console.log('No JSON found in diagnostic response:', response);
        return { shouldAskQuestions: false, questions: [], response: null };
      }

      const analysis = JSON.parse(jsonMatch[0]);
      console.log('Parsed diagnostic analysis:', analysis);
      
      return {
        shouldAskQuestions: analysis.shouldAskQuestions || false,
        questions: analysis.questions || [],
        response: analysis.response || null,
        urgency: analysis.urgency || 'low',
        category: analysis.category || 'general'
      };

    } catch (error) {
      console.error('Error in diagnostic analysis:', error);
      return { shouldAskQuestions: false, questions: [], response: null };
    }
  }

  static async generateFollowUpResponse(userAnswers, originalQuestion, currentWeek) {
    try {
      if (!process.env.GEMINI_API_KEY) {
        return "I understand your concern. Please consult your healthcare provider for personalized advice.";
      }

      const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
      const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

      const currentTime = new Date();
      const timeContext = currentTime.toLocaleString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit',
        timeZoneName: 'short'
      });

      // Get user profile context for follow-up
      const userProfile = await UserProfile.get();
      let profileContext = '';
      if (userProfile) {
        profileContext = `\nUser Profile: ${userProfile.getFormattedProfile()}`;
        const medicalContext = userProfile.getMedicalContext();
        if (medicalContext) {
          profileContext += `\nMedical Context: ${medicalContext}`;
        }
      }

      const followUpPrompt = `
Based on the user's original concern and their answers to follow-up questions, provide comprehensive, helpful advice.

Original concern: "${originalQuestion}"
Current pregnancy week: ${currentWeek || 'unknown'}
Current date and time: ${timeContext}${profileContext}
User's answers: ${userAnswers}

Provide:
1. Acknowledgment of their concern
2. Relevant information based on their answers
3. Practical advice and recommendations
4. When to seek medical attention
5. Reassurance and support

Be empathetic, informative, and always remind them to consult their healthcare provider for medical concerns.

Guidelines:
- Be specific based on their answers
- Provide actionable advice
- Include safety considerations
- Be supportive and reassuring
- Always include when to contact healthcare provider
`;

      console.log('Generating follow-up response...');
      const result = await model.generateContent(followUpPrompt);
      const response = result.response.text();
      
      return response;

    } catch (error) {
      console.error('Error generating follow-up response:', error);
      return "I understand your concern. Please consult your healthcare provider for personalized advice.";
    }
  }

  static formatQuestionsForDisplay(questions) {
    if (!questions || questions.length === 0) return '';
    
    let formatted = "To better help you, I'd like to ask a few questions:\n\n";
    questions.forEach((question, index) => {
      formatted += `${index + 1}. ${question}\n`;
    });
    formatted += "\nPlease answer these questions so I can provide you with the most helpful advice.";
    
    return formatted;
  }
}

module.exports = DiagnosticQuestioner;

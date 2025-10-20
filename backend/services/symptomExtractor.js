const { GoogleGenerativeAI } = require('@google/generative-ai');
const Symptom = require('../models/Symptom');

class SymptomExtractor {
  static async extractAndCreateSymptoms(userMessage, aiResponse, currentWeek, userId) {
    try {
      // Check if API key is available
      if (!process.env.GEMINI_API_KEY) {
        console.log('GEMINI_API_KEY not found, skipping symptom extraction');
        return [];
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

      const extractionPrompt = `
Extract any symptoms mentioned in this conversation and create symptom entries.

User message: "${userMessage}"
Assistant response: "${aiResponse}"
Current date and time: ${timeContext}

Look for symptoms like: nausea, headaches, fatigue, back pain, heartburn, mood swings, food cravings, swollen feet, insomnia, frequent urination, etc.

Return a JSON array of symptoms found. For each symptom, determine:
- type: one of nausea, fatigue, backPain, heartburn, moodSwings, foodCravings, headaches, swollenFeet, insomnia, frequentUrination, other
- severity: mild, moderate, or severe (default to mild if not specified)
- notes: natural, user-friendly description of the symptom context (e.g., "Started this morning", "After eating", "During sleep", "Worse in the evening")

Return format (JSON only, no other text):
[
  {
    "type": "headaches",
    "severity": "mild",
    "notes": "Started this morning"
  }
]

Guidelines for notes:
- Write from the user's perspective
- Include timing, triggers, or context if mentioned
- Keep it natural and helpful
- Don't mention "user mentioned" or "extracted from chat"
- If no specific context, leave notes empty or null

Only extract symptoms that are explicitly mentioned by the user. If no symptoms are mentioned, return an empty array [].
`;

      console.log('Attempting symptom extraction...');
      const result = await model.generateContent(extractionPrompt);
      const response = result.response.text();
      
      console.log('Symptom extraction response:', response);
      
      // Clean the response to extract JSON
      const jsonMatch = response.match(/\[[\s\S]*\]/);
      if (!jsonMatch) {
        console.log('No JSON found in symptom extraction response:', response);
        return [];
      }

      const symptoms = JSON.parse(jsonMatch[0]);
      console.log('Parsed symptoms:', symptoms);
      
      // Validate and create symptom entries
      const createdSymptoms = [];
      for (const symptomData of symptoms) {
        if (symptomData.type) {
          try {
            // Map string types to enum values
            const symptomType = SymptomExtractor.mapSymptomType(symptomData.type);
            const severity = SymptomExtractor.mapSeverity(symptomData.severity);
            
            const now = new Date();
            // Generate user-friendly notes
            let notes = symptomData.notes;
            if (!notes || notes.includes('User mentioned') || notes.includes('extracted from chat')) {
              // Generate natural notes based on symptom type and severity
              notes = SymptomExtractor.generateNaturalNotes(symptomType, severity);
            }
            
            const symptom = new Symptom({
              userId: userId,
              type: symptomType,
              severity: severity,
              dateTime: now,
              notes: notes,
              createdAt: now
            });
            
            await symptom.save();
            createdSymptoms.push(symptom);
            console.log(`Created symptom: ${symptomType} (${severity})`);
          } catch (error) {
            console.error('Error creating symptom:', error);
          }
        }
      }

      return createdSymptoms;

    } catch (error) {
      console.error('Error extracting symptoms:', error);
      return [];
    }
  }

  static mapSymptomType(typeString) {
    const typeMap = {
      'nausea': 'nausea',
      'fatigue': 'fatigue',
      'backPain': 'backPain',
      'back_pain': 'backPain',
      'heartburn': 'heartburn',
      'moodSwings': 'moodSwings',
      'mood_swings': 'moodSwings',
      'foodCravings': 'foodCravings',
      'food_cravings': 'foodCravings',
      'headaches': 'headaches',
      'headache': 'headaches',
      'swollenFeet': 'swollenFeet',
      'swollen_feet': 'swollenFeet',
      'insomnia': 'insomnia',
      'frequentUrination': 'frequentUrination',
      'frequent_urination': 'frequentUrination'
    };
    
    return typeMap[typeString] || 'other';
  }

  static mapSeverity(severityString) {
    if (!severityString) return 'mild';
    
    const severityMap = {
      'mild': 'mild',
      'moderate': 'moderate',
      'severe': 'severe'
    };
    
    return severityMap[severityString.toLowerCase()] || 'mild';
  }

  static generateNaturalNotes(symptomType, severity) {
    const timeOfDay = new Date().getHours();
    let timeContext = '';
    
    if (timeOfDay < 12) {
      timeContext = 'This morning';
    } else if (timeOfDay < 18) {
      timeContext = 'This afternoon';
    } else {
      timeContext = 'This evening';
    }

    const naturalNotes = {
      'headaches': severity === 'severe' ? `${timeContext} - severe pain` : `${timeContext}`,
      'nausea': severity === 'severe' ? `${timeContext} - feeling very sick` : `${timeContext}`,
      'fatigue': `${timeContext} - feeling tired`,
      'backPain': severity === 'severe' ? `${timeContext} - severe discomfort` : `${timeContext}`,
      'heartburn': `${timeContext} - after eating`,
      'moodSwings': `${timeContext}`,
      'foodCravings': `${timeContext}`,
      'swollenFeet': `${timeContext}`,
      'insomnia': 'Having trouble sleeping',
      'frequentUrination': `${timeContext}`,
      'other': `${timeContext}`
    };

    return naturalNotes[symptomType] || `${timeContext}`;
  }
}

module.exports = SymptomExtractor;

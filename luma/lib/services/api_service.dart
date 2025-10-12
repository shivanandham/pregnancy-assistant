import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/pregnancy.dart';
import '../models/symptom.dart';
import '../models/appointment.dart';
import '../models/weight_entry.dart';
import '../models/user_profile.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration timeout = ApiConfig.timeout;
  
  // Headers for API requests
  static Map<String, String> get _headers => ApiConfig.headers;

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Pregnancy API
  static Future<Pregnancy?> getPregnancyData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pregnancy'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Pregnancy.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting pregnancy data: $e');
      return null;
    }
  }

  static Future<Pregnancy?> savePregnancyData(Pregnancy pregnancy) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pregnancy'),
        headers: _headers,
        body: jsonEncode(pregnancy.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Pregnancy.fromJson(data['data']);
        } else {
        }
      }
      return null;
    } catch (e) {
      print('❌ Error saving pregnancy data: $e');
      return null;
    }
  }

  // Symptoms API
  static Future<List<Symptom>> getSymptoms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/symptoms'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final symptoms = (data['data'] as List)
              .map((item) {
                return Symptom.fromJson(item);
              })
              .toList();
          return symptoms;
        }
      }
      return [];
    } catch (e) {
      print('Error getting symptoms: $e');
      return [];
    }
  }

  static Future<Symptom?> addSymptom(Symptom symptom) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/symptoms'),
        headers: _headers,
        body: jsonEncode(symptom.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Symptom.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding symptom: $e');
      return null;
    }
  }

  static Future<bool> deleteSymptom(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/symptoms/$id'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting symptom: $e');
      return false;
    }
  }

  // Appointments API
  static Future<List<Appointment>> getAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Appointment.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  static Future<List<Appointment>> getUpcomingAppointments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/appointments/upcoming'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => Appointment.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting upcoming appointments: $e');
      return [];
    }
  }

  static Future<Appointment?> addAppointment(Appointment appointment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/appointments'),
        headers: _headers,
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Appointment.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding appointment: $e');
      return null;
    }
  }

  static Future<Appointment?> updateAppointment(String id, Appointment appointment) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/appointments/$id'),
        headers: _headers,
        body: jsonEncode(appointment.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Appointment.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error updating appointment: $e');
      return null;
    }
  }

  static Future<bool> deleteAppointment(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/appointments/$id'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting appointment: $e');
      return false;
    }
  }

  // Weight API
  static Future<List<WeightEntry>> getWeightEntries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/weight'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => WeightEntry.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting weight entries: $e');
      return [];
    }
  }

  static Future<WeightEntry?> addWeightEntry(WeightEntry weightEntry) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/weight'),
        headers: _headers,
        body: jsonEncode(weightEntry.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return WeightEntry.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error adding weight entry: $e');
      return null;
    }
  }

  static Future<bool> deleteWeightEntry(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/weight/$id'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting weight entry: $e');
      return false;
    }
  }

  // Chat API
  static Future<ChatMessage?> sendChatMessage({
    required String message,
    String? context,
    String? sessionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: _headers,
        body: jsonEncode({
          'message': message,
          'context': context,
          'sessionId': sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final assistantMessage = data['data']['assistantMessage'];
          
          return ChatMessage(
            id: assistantMessage['id']?.toString() ?? '',
            content: assistantMessage['content']?.toString() ?? '',
            type: MessageType.assistant,
            timestamp: DateTime.parse(assistantMessage['timestamp']?.toString() ?? DateTime.now().toIso8601String()),
            context: assistantMessage['context']?.toString(),
            isError: assistantMessage['isError'] ?? false,
            isDiagnostic: assistantMessage['isDiagnostic'] ?? false,
            diagnosticQuestions: assistantMessage['diagnosticQuestions'] != null 
                ? List<String>.from(assistantMessage['diagnosticQuestions']) 
                : null,
            diagnosticAnswers: assistantMessage['diagnosticAnswers'],
            parentMessageId: assistantMessage['parentMessageId']?.toString(),
            sessionId: assistantMessage['sessionId']?.toString(),
          );
        }
      }
      
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I encountered an error. Please try again.',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        context: context,
        isError: true,
        isDiagnostic: false,
      );
    } catch (e) {
      print('Error sending chat message: $e');
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        context: context,
        isError: true,
        isDiagnostic: false,
      );
    }
  }

  static Future<List<ChatMessage>> getChatHistory({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/history?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return (data['data'] as List)
              .map((item) => ChatMessage.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting chat history: $e');
      return [];
    }
  }

  static Future<bool> clearChatHistory() async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat/history'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing chat history: $e');
      return false;
    }
  }

  // Knowledge API
  static Future<List<Map<String, dynamic>>> searchKnowledge(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/knowledge/search?q=${Uri.encodeComponent(query)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error searching knowledge: $e');
      return [];
    }
  }

  // User Profile API
  static Future<UserProfile?> getUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserProfile.fromJson(data['data']);
        } else {
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  static Future<UserProfile?> saveUserProfile(UserProfile profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user-profile'),
        headers: _headers,
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserProfile.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error saving user profile: $e');
      return null;
    }
  }

  static Future<UserProfile?> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/api/user-profile'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return UserProfile.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfileContext() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-profile/context'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting profile context: $e');
      return null;
    }
  }

  // Chat Session Methods
  static Future<List<ChatSession>> getChatSessions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final sessions = (data['data'] as List)
              .map((session) => ChatSession.fromJson(session))
              .toList();
          return sessions;
        }
      }
      return [];
    } catch (e) {
      print('Error getting chat sessions: $e');
      return [];
    }
  }

  static Future<ChatSession?> getActiveChatSession() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions/active'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ChatSession.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting active chat session: $e');
      return null;
    }
  }

  static Future<ChatSession?> createChatSession({String? title}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions'),
        headers: ApiConfig.headers,
        body: json.encode({'title': title ?? 'New Chat'}),
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChatSession.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error creating chat session: $e');
      return null;
    }
  }

  static Future<List<ChatMessage>> getChatSessionMessages(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions/$sessionId'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data']['messages'] != null) {
          final messages = (data['data']['messages'] as List)
              .map((message) => ChatMessage.fromJson(message))
              .toList();
          return messages;
        }
      }
      return [];
    } catch (e) {
      print('Error getting session messages: $e');
      return [];
    }
  }

  static Future<bool> setActiveChatSession(String sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions/$sessionId/activate'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting active chat session: $e');
      return false;
    }
  }

  static Future<bool> updateChatSessionTitle(String sessionId, String title) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions/$sessionId/title'),
        headers: ApiConfig.headers,
        body: json.encode({'title': title}),
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating chat session title: $e');
      return false;
    }
  }

  static Future<bool> deleteChatSession(String sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/chat-sessions/$sessionId'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting chat session: $e');
      return false;
    }
  }
}

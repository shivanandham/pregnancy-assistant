import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'http_client.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/pregnancy.dart';
import '../models/symptom.dart';
import '../models/appointment.dart';
import '../models/weight_entry.dart';
import '../models/user_profile.dart';
import '../models/home_data.dart';
import '../models/pregnancy_tip.dart';
import '../models/pregnancy_milestone.dart';
import '../models/daily_checklist.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration timeout = ApiConfig.timeout;

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await AuthenticatedHttpClient.healthCheck();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Pregnancy API
  static Future<Pregnancy?> getPregnancyData() async {
    try {
      final response = await AuthenticatedHttpClient.get('/api/pregnancy');

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
      final response = await AuthenticatedHttpClient.post(
        '/api/pregnancy',
        body: pregnancy.toJson(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
      final response = await AuthenticatedHttpClient.get('/api/user-profile');

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
      final response = await AuthenticatedHttpClient.post(
        '/api/user-profile',
        body: profile.toJson(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
        headers: await AuthenticatedHttpClient.getHeaders(),
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
      final response = await AuthenticatedHttpClient.get('/api/chat-sessions');

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
      final response = await AuthenticatedHttpClient.get('/api/chat-sessions/active');

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
      final response = await AuthenticatedHttpClient.post(
        '/api/chat-sessions',
        body: {'title': title ?? 'New Chat'},
      );

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
      final response = await AuthenticatedHttpClient.get('/api/chat-sessions/$sessionId');

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
      final response = await AuthenticatedHttpClient.put('/api/chat-sessions/$sessionId/activate');

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting active chat session: $e');
      return false;
    }
  }

  static Future<bool> updateChatSessionTitle(String sessionId, String title) async {
    try {
      final response = await AuthenticatedHttpClient.put(
        '/api/chat-sessions/$sessionId/title',
        body: {'title': title},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating chat session title: $e');
      return false;
    }
  }

  static Future<bool> deleteChatSession(String sessionId) async {
    try {
      final response = await AuthenticatedHttpClient.delete('/api/chat-sessions/$sessionId');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting chat session: $e');
      return false;
    }
  }

  // Home screen data
  static Future<HomeData?> getHomeData() async {
    try {
      final response = await AuthenticatedHttpClient.get('/api/home');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return HomeData.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting home data: $e');
      return null;
    }
  }

  // Get tips for a specific week
  static Future<List<PregnancyTip>> getTipsForWeek(int week) async {
    try {
      final response = await AuthenticatedHttpClient.get('/api/home/tips/$week');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List<dynamic>)
              .map((tip) => PregnancyTip.fromJson(tip))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting tips for week: $e');
      return [];
    }
  }

  // Get milestones for a specific week
  static Future<Map<String, List<PregnancyMilestone>>> getMilestonesForWeek(int week) async {
    try {
      final response = await AuthenticatedHttpClient.get('/api/home/milestones/$week');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final milestonesData = data['data'];
          return {
            'current': (milestonesData['current'] as List<dynamic>)
                .map((milestone) => PregnancyMilestone.fromJson(milestone))
                .toList(),
            'upcoming': (milestonesData['upcoming'] as List<dynamic>)
                .map((milestone) => PregnancyMilestone.fromJson(milestone))
                .toList(),
            'recent': (milestonesData['recent'] as List<dynamic>)
                .map((milestone) => PregnancyMilestone.fromJson(milestone))
                .toList(),
          };
        }
      }
      return {'current': [], 'upcoming': [], 'recent': []};
    } catch (e) {
      print('Error getting milestones for week: $e');
      return {'current': [], 'upcoming': [], 'recent': []};
    }
  }

  // Get daily checklist for a specific week
  static Future<Map<String, dynamic>> getChecklistForWeek(int week) async {
    try {
      final response = await AuthenticatedHttpClient.get('/api/home/checklist/$week');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final checklistData = data['data'];
          return {
            'tasks': (checklistData['tasks'] as List<dynamic>)
                .map((task) => DailyChecklist.fromJson(task))
                .toList(),
            'byCategory': _parseChecklistByCategory(checklistData['byCategory']),
          };
        }
      }
      return {'tasks': <DailyChecklist>[], 'byCategory': <String, List<DailyChecklist>>{}};
    } catch (e) {
      print('Error getting checklist for week: $e');
      return {'tasks': <DailyChecklist>[], 'byCategory': <String, List<DailyChecklist>>{}};
    }
  }

  static Map<String, List<DailyChecklist>> _parseChecklistByCategory(dynamic data) {
    if (data == null) return {};
    
    Map<String, List<DailyChecklist>> result = {};
    (data as Map<String, dynamic>).forEach((category, tasks) {
      result[category] = (tasks as List<dynamic>)
          .map((task) => DailyChecklist.fromJson(task))
          .toList();
    });
    
    return result;
  }

  // Checklist completion methods
  static Future<bool> toggleChecklistCompletion(String checklistItemId, {DateTime? date}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/home/checklist/$checklistItemId/toggle'),
        headers: await AuthenticatedHttpClient.getHeaders(),
        body: jsonEncode({
          'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error toggling checklist completion: $e');
      return false;
    }
  }

  static Future<List<String>> getChecklistCompletions(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
      final response = await http.get(
        Uri.parse('$baseUrl/api/home/checklist/completions/$dateString'),
        headers: await AuthenticatedHttpClient.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final completions = data['data']['completions'] as List;
          return completions.map((completion) => completion['checklistItemId'] as String).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error getting checklist completions: $e');
      return [];
    }
  }

}

import 'package:flutter/foundation.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatSessionProvider with ChangeNotifier {
  List<ChatSession> _sessions = [];
  ChatSession? _activeSession;
  List<ChatMessage> _currentMessages = [];
  bool _isLoading = false;
  String? _error;
  
  // Callback to notify ChatProvider when session changes
  Function(String sessionId)? onSessionChanged;

  // Getters
  List<ChatSession> get sessions => _sessions;
  ChatSession? get activeSession => _activeSession;
  List<ChatMessage> get currentMessages => _currentMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all chat sessions
  Future<void> loadSessions() async {
    _setLoading(true);
    _clearError();

    try {
      final sessions = await ApiService.getChatSessions();
      _sessions = sessions;
      
      // Find active session
      _activeSession = sessions.firstWhere(
        (session) => session.isActive,
        orElse: () => sessions.isNotEmpty ? sessions.first : ChatSession(
          id: '',
          title: 'New Chat',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messageCount: 0,
          isActive: false,
        ),
      );


      // Load messages for active session
      if (_activeSession != null && _activeSession!.id.isNotEmpty) {
        await loadSessionMessages(_activeSession!.id);
        // Notify ChatProvider to load messages for this session
        onSessionChanged?.call(_activeSession!.id);
      } else {
        // No active session, clear messages
        onSessionChanged?.call('');
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat sessions: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error loading sessions - $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load messages for a specific session
  Future<void> loadSessionMessages(String sessionId) async {
    try {
      final messages = await ApiService.getChatSessionMessages(sessionId);
      _currentMessages = messages;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load session messages: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error loading messages - $e');
      }
    }
  }

  // Create new chat session
  Future<ChatSession?> createNewSession({String? title}) async {
    _setLoading(true);
    _clearError();

    try {
      final newSession = await ApiService.createChatSession(title: title);
      if (newSession != null) {
        _sessions.insert(0, newSession);
        _activeSession = newSession;
        _currentMessages = [];
        
        // Notify ChatProvider to clear messages for new session
        onSessionChanged?.call('');
        
        notifyListeners();
        return newSession;
      }
    } catch (e) {
      _setError('Failed to create new session: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error creating session - $e');
      }
    } finally {
      _setLoading(false);
    }
    return null;
  }

  // Switch to a different session
  Future<void> switchToSession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      // Set as active session on backend
      await ApiService.setActiveChatSession(sessionId);
      
      // Update local state
      _activeSession = _sessions.firstWhere(
        (session) => session.id == sessionId,
      );
      
      // Load messages for this session
      await loadSessionMessages(sessionId);
      
        // Notify ChatProvider to load messages for this session
        onSessionChanged?.call(sessionId);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to switch session: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error switching session - $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Update session title
  Future<void> updateSessionTitle(String sessionId, String title) async {
    try {
      await ApiService.updateChatSessionTitle(sessionId, title);
      
      // Update local state
      final index = _sessions.indexWhere((session) => session.id == sessionId);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(
          title: title,
          updatedAt: DateTime.now(),
        );
        
        if (_activeSession?.id == sessionId) {
          _activeSession = _sessions[index];
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update session title: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error updating title - $e');
      }
    }
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    try {
      await ApiService.deleteChatSession(sessionId);
      
      // Remove from local state
      _sessions.removeWhere((session) => session.id == sessionId);
      
      // If we deleted the active session, switch to another one or create new
      if (_activeSession?.id == sessionId) {
        if (_sessions.isNotEmpty) {
          await switchToSession(_sessions.first.id);
        } else {
          _activeSession = null;
          _currentMessages = [];
        }
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete session: $e');
      if (kDebugMode) {
        print('❌ ChatSessionProvider: Error deleting session - $e');
      }
    }
  }

  // Add message to current session
  void addMessage(ChatMessage message) {
    _currentMessages.add(message);
    
    // Update message count for active session
    if (_activeSession != null) {
      final index = _sessions.indexWhere((session) => session.id == _activeSession!.id);
      if (index != -1) {
        _sessions[index] = _sessions[index].copyWith(
          messageCount: _sessions[index].messageCount + 1,
          updatedAt: DateTime.now(),
        );
        _activeSession = _sessions[index];
      }
    }
    
    notifyListeners();
  }

  // Clear current messages
  void clearCurrentMessages() {
    _currentMessages = [];
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}


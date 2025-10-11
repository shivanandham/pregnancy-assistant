import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _error;

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get error => _error;

  // Load chat history
  Future<void> loadChatHistory() async {
    _setLoading(true);
    _clearError();

    try {
      _messages = await ApiService.getChatHistory();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load chat history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Send message
  Future<void> sendMessage(String content, {String? context}) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      context: context,
    );

    _messages.add(userMessage);
    _setTyping(true);
    _clearError();
    notifyListeners();

    try {
      final assistantMessage = await ApiService.sendChatMessage(
        message: content,
        context: context,
      );

      if (assistantMessage != null) {
        _messages.add(assistantMessage);
      } else {
        // Add error message if no response
        final errorMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: 'Sorry, I encountered an error. Please try again.',
          type: MessageType.assistant,
          timestamp: DateTime.now(),
          context: context,
          isError: true,
        );
        _messages.add(errorMessage);
      }
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'Sorry, I\'m having trouble connecting. Please check your internet connection and try again.',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        context: context,
        isError: true,
      );
      _messages.add(errorMessage);
      _setError('Failed to send message: $e');
    } finally {
      _setTyping(false);
    }
  }

  // Clear chat history
  Future<void> clearChatHistory() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await ApiService.clearChatHistory();
      if (success) {
        _messages.clear();
        notifyListeners();
      } else {
        _setError('Failed to clear chat history');
      }
    } catch (e) {
      _setError('Failed to clear chat history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add quick action message
  void addQuickActionMessage(String content) {
    sendMessage(content);
  }

  // Get recent messages
  List<ChatMessage> getRecentMessages(int count) {
    if (_messages.length <= count) return _messages;
    return _messages.sublist(_messages.length - count);
  }

  // Get messages by type
  List<ChatMessage> getMessagesByType(MessageType type) {
    return _messages.where((message) => message.type == type).toList();
  }

  // Get user messages
  List<ChatMessage> get userMessages => getMessagesByType(MessageType.user);

  // Get assistant messages
  List<ChatMessage> get assistantMessages => getMessagesByType(MessageType.assistant);

  // Check if there are any error messages
  bool get hasErrors => _messages.any((message) => message.isError);

  // Get last message
  ChatMessage? get lastMessage {
    if (_messages.isEmpty) return null;
    return _messages.last;
  }

  // Get last user message
  ChatMessage? get lastUserMessage {
    final userMessages = this.userMessages;
    if (userMessages.isEmpty) return null;
    return userMessages.last;
  }

  // Get last assistant message
  ChatMessage? get lastAssistantMessage {
    final assistantMessages = this.assistantMessages;
    if (assistantMessages.isEmpty) return null;
    return assistantMessages.last;
  }

  // Check if chat is empty
  bool get isEmpty => _messages.isEmpty;

  // Get message count
  int get messageCount => _messages.length;

  // Refresh chat
  Future<void> refresh() async {
    await loadChatHistory();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Quick action messages
  static const List<String> quickActions = [
    'What should I eat during pregnancy?',
    'How can I manage morning sickness?',
    'What exercises are safe during pregnancy?',
    'What symptoms should I watch for?',
    'Tell me about my current week',
    'What appointments do I need?',
    'How much weight should I gain?',
    'What can I do for back pain?',
  ];

  // Get quick action message
  String getQuickActionMessage(int index) {
    if (index >= 0 && index < quickActions.length) {
      return quickActions[index];
    }
    return quickActions.first;
  }

  // Add welcome message if chat is empty
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        id: 'welcome',
        content: 'Hello! I\'m your pregnancy assistant. I\'m here to help you with any questions about your pregnancy journey. How can I assist you today?',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }

  // Clear all data
  void clearAllData() {
    _messages.clear();
    _clearError();
    notifyListeners();
  }
}

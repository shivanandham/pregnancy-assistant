
enum MessageType {
  user,
  assistant,
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final String? context; // Additional context like current week
  final bool isError;
  final bool isDiagnostic;
  final List<String>? diagnosticQuestions;
  final Map<String, dynamic>? diagnosticAnswers;
  final String? parentMessageId;
  final String? sessionId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.context,
    this.isError = false,
    this.isDiagnostic = false,
    this.diagnosticQuestions,
    this.diagnosticAnswers,
    this.parentMessageId,
    this.sessionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'isError': isError,
      'isDiagnostic': isDiagnostic,
      'diagnosticQuestions': diagnosticQuestions,
      'diagnosticAnswers': diagnosticAnswers,
      'parentMessageId': parentMessageId,
      'sessionId': sessionId,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      context: json['context']?.toString(),
      isError: json['isError'] ?? false,
      isDiagnostic: json['isDiagnostic'] ?? false,
      diagnosticQuestions: json['diagnosticQuestions'] != null 
          ? List<String>.from(json['diagnosticQuestions']) 
          : null,
      diagnosticAnswers: json['diagnosticAnswers'],
      parentMessageId: json['parentMessageId']?.toString(),
      sessionId: json['sessionId']?.toString(),
    );
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    String? context,
    bool? isError,
    bool? isDiagnostic,
    List<String>? diagnosticQuestions,
    Map<String, dynamic>? diagnosticAnswers,
    String? parentMessageId,
    String? sessionId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
      isError: isError ?? this.isError,
      isDiagnostic: isDiagnostic ?? this.isDiagnostic,
      diagnosticQuestions: diagnosticQuestions ?? this.diagnosticQuestions,
      diagnosticAnswers: diagnosticAnswers ?? this.diagnosticAnswers,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

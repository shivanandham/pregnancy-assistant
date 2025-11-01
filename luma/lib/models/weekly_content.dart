class WeeklyContent {
  final String id;
  final String userId;
  final int week;
  final String? title;
  final List<String> highlights;
  final List<String> facts;
  final List<String> thingsToDo;
  final Map<String, dynamic>? content;
  final DateTime createdAt;
  final DateTime expiresAt;

  WeeklyContent({
    required this.id,
    required this.userId,
    required this.week,
    this.title,
    required this.highlights,
    required this.facts,
    required this.thingsToDo,
    this.content,
    required this.createdAt,
    required this.expiresAt,
  });

  factory WeeklyContent.fromJson(Map<String, dynamic> json) {
    return WeeklyContent(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      week: json['week'] ?? 0,
      title: json['title'],
      highlights: (json['highlights'] as List<dynamic>?)
          ?.map((h) => h.toString())
          .toList() ?? [],
      facts: (json['facts'] as List<dynamic>?)
          ?.map((f) => f.toString())
          .toList() ?? [],
      thingsToDo: (json['thingsToDo'] as List<dynamic>?)
          ?.map((t) => t.toString())
          .toList() ?? [],
      content: json['content'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'week': week,
      'title': title,
      'highlights': highlights,
      'facts': facts,
      'thingsToDo': thingsToDo,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}


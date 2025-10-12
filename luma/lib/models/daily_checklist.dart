class DailyChecklist {
  final String id;
  final String task;
  final String category;
  final int? week;
  final int? trimester;
  final String frequency;
  final bool important;
  final bool personalized;
  final DateTime? generatedAt;

  DailyChecklist({
    required this.id,
    required this.task,
    required this.category,
    this.week,
    this.trimester,
    required this.frequency,
    required this.important,
    this.personalized = false,
    this.generatedAt,
  });

  factory DailyChecklist.fromJson(Map<String, dynamic> json) {
    return DailyChecklist(
      id: json['id'] ?? '',
      task: json['task'] ?? '',
      category: json['category'] ?? '',
      week: json['week'],
      trimester: json['trimester'],
      frequency: json['frequency'] ?? 'daily',
      important: json['important'] ?? false,
      personalized: json['personalized'] ?? false,
      generatedAt: json['generatedAt'] != null ? DateTime.parse(json['generatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task': task,
      'category': category,
      'week': week,
      'trimester': trimester,
      'frequency': frequency,
      'important': important,
      'personalized': personalized,
      'generatedAt': generatedAt?.toIso8601String(),
    };
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'health':
        return 'Health';
      case 'nutrition':
        return 'Nutrition';
      case 'exercise':
        return 'Exercise';
      case 'emotional':
        return 'Emotional Well-being';
      case 'preparation':
        return 'Preparation';
      default:
        return category;
    }
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'health':
        return '💊';
      case 'nutrition':
        return '🥗';
      case 'exercise':
        return '🏃‍♀️';
      case 'emotional':
        return '💝';
      case 'preparation':
        return '📋';
      default:
        return '✅';
    }
  }

  String get frequencyDisplayName {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'as_needed':
        return 'As Needed';
      default:
        return frequency;
    }
  }

  DailyChecklist copyWith({
    String? id,
    String? task,
    String? category,
    int? week,
    int? trimester,
    String? frequency,
    bool? important,
    bool? personalized,
    DateTime? generatedAt,
  }) {
    return DailyChecklist(
      id: id ?? this.id,
      task: task ?? this.task,
      category: category ?? this.category,
      week: week ?? this.week,
      trimester: trimester ?? this.trimester,
      frequency: frequency ?? this.frequency,
      important: important ?? this.important,
      personalized: personalized ?? this.personalized,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

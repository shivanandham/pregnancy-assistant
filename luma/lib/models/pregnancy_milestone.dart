class PregnancyMilestone {
  final int week;
  final String title;
  final String description;
  final String category;
  final bool important;

  PregnancyMilestone({
    required this.week,
    required this.title,
    required this.description,
    required this.category,
    required this.important,
  });

  factory PregnancyMilestone.fromJson(Map<String, dynamic> json) {
    return PregnancyMilestone(
      week: json['week'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      important: json['important'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'title': title,
      'description': description,
      'category': category,
      'important': important,
    };
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'confirmation':
        return 'Pregnancy Confirmation';
      case 'development':
        return 'Baby Development';
      case 'medical':
        return 'Medical Checkup';
      case 'milestone':
        return 'Important Milestone';
      case 'preparation':
        return 'Preparation';
      default:
        return category;
    }
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'confirmation':
        return '✅';
      case 'development':
        return '👶';
      case 'medical':
        return '🏥';
      case 'milestone':
        return '🎯';
      case 'preparation':
        return '📋';
      default:
        return '📅';
    }
  }

  String get trimester {
    if (week <= 12) return 'First Trimester';
    if (week <= 26) return 'Second Trimester';
    return 'Third Trimester';
  }

  PregnancyMilestone copyWith({
    int? week,
    String? title,
    String? description,
    String? category,
    bool? important,
  }) {
    return PregnancyMilestone(
      week: week ?? this.week,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      important: important ?? this.important,
    );
  }
}

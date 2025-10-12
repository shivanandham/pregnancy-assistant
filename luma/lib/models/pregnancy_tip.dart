import '../services/device_timezone_service.dart';

class PregnancyTip {
  final String id;
  final int week;
  final String tip;
  final String category;
  final DateTime createdAt;
  final DateTime expiresAt;

  PregnancyTip({
    required this.id,
    required this.week,
    required this.tip,
    required this.category,
    required this.createdAt,
    required this.expiresAt,
  });

  factory PregnancyTip.fromJson(Map<String, dynamic> json) {
    return PregnancyTip(
      id: json['id'] ?? '',
      week: json['week'] ?? 0,
      tip: json['tip'] ?? '',
      category: json['category'] ?? '',
      createdAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['createdAt'])),
      expiresAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['expiresAt'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week': week,
      'tip': tip,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'nutrition':
        return 'Nutrition';
      case 'exercise':
        return 'Exercise';
      case 'health':
        return 'Health';
      case 'emotional':
        return 'Emotional Well-being';
      case 'preparation':
        return 'Preparation';
      case 'medical':
        return 'Medical';
      default:
        return category;
    }
  }

  String get categoryIcon {
    switch (category.toLowerCase()) {
      case 'nutrition':
        return '🥗';
      case 'exercise':
        return '🏃‍♀️';
      case 'health':
        return '💊';
      case 'emotional':
        return '💝';
      case 'preparation':
        return '📋';
      case 'medical':
        return '🏥';
      default:
        return '💡';
    }
  }

  PregnancyTip copyWith({
    String? id,
    int? week,
    String? tip,
    String? category,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PregnancyTip(
      id: id ?? this.id,
      week: week ?? this.week,
      tip: tip ?? this.tip,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

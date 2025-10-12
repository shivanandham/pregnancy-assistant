import '../services/device_timezone_service.dart';

class Pregnancy {
  final String id;
  final DateTime dueDate;
  final DateTime lastMenstrualPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  Pregnancy({
    required this.id,
    required this.dueDate,
    required this.lastMenstrualPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
  });

  // Calculate current week of pregnancy
  int get currentWeek {
    final now = DeviceTimezoneService.now();
    final daysSinceLMP = now.difference(lastMenstrualPeriod).inDays;
    return (daysSinceLMP / 7).floor() + 1;
  }

  // Calculate days until due date
  int get daysUntilDueDate {
    final now = DeviceTimezoneService.now();
    return dueDate.difference(now).inDays;
  }

  // Get current trimester
  int get currentTrimester {
    if (currentWeek <= 12) return 1;
    if (currentWeek <= 28) return 2;
    return 3;
  }

  // Get progress percentage
  double get progressPercentage {
    final totalDays = dueDate.difference(lastMenstrualPeriod).inDays;
    final elapsedDays = DeviceTimezoneService.now().difference(lastMenstrualPeriod).inDays;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dueDate': dueDate.toIso8601String(),
      'lastMenstrualPeriod': lastMenstrualPeriod.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory Pregnancy.fromJson(Map<String, dynamic> json) {
    return Pregnancy(
      id: json['id'] ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      lastMenstrualPeriod: DateTime.parse(json['lastMenstrualPeriod']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
    );
  }

  Pregnancy copyWith({
    String? id,
    DateTime? dueDate,
    DateTime? lastMenstrualPeriod,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      dueDate: dueDate ?? this.dueDate,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}

import '../services/device_timezone_service.dart';

enum SymptomType {
  nausea,
  fatigue,
  backPain,
  heartburn,
  moodSwings,
  foodCravings,
  headaches,
  swollenFeet,
  insomnia,
  frequentUrination,
  other,
}

enum SeverityLevel {
  mild,
  moderate,
  severe,
}

class Symptom {
  final String id;
  final SymptomType type;
  final SeverityLevel severity;
  final DateTime dateTime;
  final String? notes;
  final String? customType; // For 'other' type
  final DateTime createdAt;

  Symptom({
    required this.id,
    required this.type,
    required this.severity,
    required this.dateTime,
    this.notes,
    this.customType,
    required this.createdAt,
  });

  String get displayName {
    if (type == SymptomType.other && customType != null) {
      return customType!;
    }
    return type.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'customType': customType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] ?? '',
      type: SymptomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SymptomType.other,
      ),
      severity: SeverityLevel.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => SeverityLevel.mild,
      ),
      dateTime: _parseDateTime(json['dateTime']),
      notes: json['notes'],
      customType: json['customType'],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    try {
      if (dateValue is String) {
        // Handle invalid timestamp strings like "1760179205421.0"
        if (dateValue.contains('.0') && RegExp(r'^\d+\.0$').hasMatch(dateValue)) {
          final timestamp = double.parse(dateValue);
          return DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
        }
        
        // Parse the UTC datetime and convert to device timezone
        final utcDateTime = DateTime.parse(dateValue);
        return DeviceTimezoneService.toDeviceTimezone(utcDateTime);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      } else if (dateValue is double) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue.toInt());
      }
    } catch (e) {
      print('Error parsing date: $dateValue, error: $e');
    }
    // Fallback to current time if parsing fails
    return DeviceTimezoneService.now();
  }

  Symptom copyWith({
    String? id,
    SymptomType? type,
    SeverityLevel? severity,
    DateTime? dateTime,
    String? notes,
    String? customType,
    DateTime? createdAt,
  }) {
    return Symptom(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      customType: customType ?? this.customType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

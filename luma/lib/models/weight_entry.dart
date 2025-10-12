
import '../services/device_timezone_service.dart';

class WeightEntry {
  final String id;
  final double weight; // in kg
  final DateTime dateTime;
  final String? notes;
  final DateTime createdAt;

  WeightEntry({
    required this.id,
    required this.weight,
    required this.dateTime,
    this.notes,
    required this.createdAt,
  });

  // Convert kg to lbs
  double get weightInPounds {
    return weight * 2.20462;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weight': weight,
      'dateTime': dateTime.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] ?? '',
      weight: (json['weight'] ?? 0.0).toDouble(),
      dateTime: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['dateTime'])),
      notes: json['notes'],
      createdAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['createdAt'])),
    );
  }

  WeightEntry copyWith({
    String? id,
    double? weight,
    DateTime? dateTime,
    String? notes,
    DateTime? createdAt,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      weight: weight ?? this.weight,
      dateTime: dateTime ?? this.dateTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

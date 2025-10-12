
import '../services/device_timezone_service.dart';

enum AppointmentType {
  prenatal,
  ultrasound,
  bloodTest,
  glucoseTest,
  consultation,
  other,
}

class Appointment {
  final String id;
  final String title;
  final AppointmentType type;
  final DateTime dateTime;
  final String? location;
  final String? doctor;
  final String? notes;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.title,
    required this.type,
    required this.dateTime,
    this.location,
    this.doctor,
    this.notes,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName {
    return type.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
  }

  bool get isUpcoming {
    return dateTime.isAfter(DeviceTimezoneService.now()) && !isCompleted;
  }

  bool get isPast {
    return dateTime.isBefore(DeviceTimezoneService.now()) || isCompleted;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'doctor': doctor,
      'notes': notes,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: AppointmentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AppointmentType.other,
      ),
      dateTime: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['dateTime'])),
      location: json['location'],
      doctor: json['doctor'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['createdAt'])),
      updatedAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['updatedAt'])),
    );
  }

  Appointment copyWith({
    String? id,
    String? title,
    AppointmentType? type,
    DateTime? dateTime,
    String? location,
    String? doctor,
    String? notes,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      doctor: doctor ?? this.doctor,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

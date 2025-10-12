import '../services/device_timezone_service.dart';

class UserProfile {
  final String id;
  final double? height; // in cm
  final double? weight; // in kg
  final double? prePregnancyWeight; // in kg
  final int? age;
  final String gender;
  final String? locality;
  final String? timezone;
  final List<String>? medicalHistory;
  final List<String>? allergies;
  final List<String>? medications;
  final Lifestyle? lifestyle;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.height,
    this.weight,
    this.prePregnancyWeight,
    this.age,
    this.gender = 'female',
    this.locality,
    this.timezone,
    this.medicalHistory,
    this.allergies,
    this.medications,
    this.lifestyle,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper methods
  double? get bmi {
    if (height != null && weight != null) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  double? get weightGain {
    if (prePregnancyWeight != null && weight != null) {
      return weight! - prePregnancyWeight!;
    }
    return null;
  }

  String get formattedProfile {
    final profile = <String>[];
    
    if (age != null) profile.add('Age: $age years');
    if (height != null) profile.add('Height: ${height!.toStringAsFixed(0)} cm');
    if (weight != null) profile.add('Current weight: ${weight!.toStringAsFixed(1)} kg');
    if (prePregnancyWeight != null) profile.add('Pre-pregnancy weight: ${prePregnancyWeight!.toStringAsFixed(1)} kg');
    if (bmi != null) profile.add('BMI: ${bmi!.toStringAsFixed(1)}');
    if (weightGain != null) profile.add('Weight gain: ${weightGain!.toStringAsFixed(1)} kg');
    if (locality != null) profile.add('Location: $locality');
    if (timezone != null) profile.add('Timezone: $timezone');
    
    return profile.join(', ');
  }

  String get medicalContext {
    final context = <String>[];
    
    if (medicalHistory != null && medicalHistory!.isNotEmpty) {
      context.add('Medical history: ${medicalHistory!.join(', ')}');
    }
    if (allergies != null && allergies!.isNotEmpty) {
      context.add('Allergies: ${allergies!.join(', ')}');
    }
    if (medications != null && medications!.isNotEmpty) {
      context.add('Current medications: ${medications!.join(', ')}');
    }
    if (lifestyle != null) {
      final lifestyleItems = <String>[];
      if (lifestyle!.diet != null) lifestyleItems.add('Diet: ${lifestyle!.diet}');
      if (lifestyle!.exercise != null) lifestyleItems.add('Exercise: ${lifestyle!.exercise}');
      if (lifestyle!.smoking != null) lifestyleItems.add('Smoking: ${lifestyle!.smoking}');
      if (lifestyle!.alcohol != null) lifestyleItems.add('Alcohol: ${lifestyle!.alcohol}');
      if (lifestyleItems.isNotEmpty) {
        context.add('Lifestyle: ${lifestyleItems.join(', ')}');
      }
    }
    
    return context.join('; ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'height': height,
      'weight': weight,
      'prePregnancyWeight': prePregnancyWeight,
      'age': age,
      'gender': gender,
      'locality': locality,
      'timezone': timezone,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'medications': medications,
      'lifestyle': lifestyle?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      prePregnancyWeight: json['prePregnancyWeight']?.toDouble(),
      age: json['age'],
      gender: json['gender'] ?? 'female',
      locality: json['locality'],
      timezone: json['timezone'],
      medicalHistory: json['medicalHistory'] != null 
          ? List<String>.from(json['medicalHistory']) 
          : null,
      allergies: json['allergies'] != null 
          ? List<String>.from(json['allergies']) 
          : null,
      medications: json['medications'] != null 
          ? List<String>.from(json['medications']) 
          : null,
      lifestyle: json['lifestyle'] != null 
          ? Lifestyle.fromJson(json['lifestyle']) 
          : null,
      createdAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['createdAt'])),
      updatedAt: DeviceTimezoneService.toDeviceTimezone(DateTime.parse(json['updatedAt'])),
    );
  }

  UserProfile copyWith({
    String? id,
    double? height,
    double? weight,
    double? prePregnancyWeight,
    int? age,
    String? gender,
    String? locality,
    String? timezone,
    List<String>? medicalHistory,
    List<String>? allergies,
    List<String>? medications,
    Lifestyle? lifestyle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      prePregnancyWeight: prePregnancyWeight ?? this.prePregnancyWeight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      locality: locality ?? this.locality,
      timezone: timezone ?? this.timezone,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      lifestyle: lifestyle ?? this.lifestyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Lifestyle {
  final String? diet;
  final String? exercise;
  final String? smoking;
  final String? alcohol;

  Lifestyle({
    this.diet,
    this.exercise,
    this.smoking,
    this.alcohol,
  });

  Map<String, dynamic> toJson() {
    return {
      'diet': diet,
      'exercise': exercise,
      'smoking': smoking,
      'alcohol': alcohol,
    };
  }

  factory Lifestyle.fromJson(Map<String, dynamic> json) {
    return Lifestyle(
      diet: json['diet'],
      exercise: json['exercise'],
      smoking: json['smoking'],
      alcohol: json['alcohol'],
    );
  }

  Lifestyle copyWith({
    String? diet,
    String? exercise,
    String? smoking,
    String? alcohol,
  }) {
    return Lifestyle(
      diet: diet ?? this.diet,
      exercise: exercise ?? this.exercise,
      smoking: smoking ?? this.smoking,
      alcohol: alcohol ?? this.alcohol,
    );
  }
}

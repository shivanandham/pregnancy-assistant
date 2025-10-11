import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  // Helper getters
  double? get bmi => _profile?.bmi;
  double? get weightGain => _profile?.weightGain;
  String get formattedProfile => _profile?.formattedProfile ?? 'No profile available';
  String get medicalContext => _profile?.medicalContext ?? 'No medical information available';

  // Load user profile
  Future<void> loadUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _profile = await ApiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    _setLoading(true);
    _clearError();

    try {
      final savedProfile = await ApiService.saveUserProfile(profile);
      if (savedProfile != null) {
        _profile = savedProfile;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to save profile');
        return false;
      }
    } catch (e) {
      _setError('Failed to save profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProfile = await ApiService.updateUserProfile(updates);
      if (updatedProfile != null) {
        _profile = updatedProfile;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Create new profile
  Future<bool> createProfile({
    required double height,
    required double weight,
    required int age,
    double? prePregnancyWeight,
    String gender = 'female',
    String? locality,
    String? timezone,
    List<String>? medicalHistory,
    List<String>? allergies,
    List<String>? medications,
    Lifestyle? lifestyle,
  }) async {
    final newProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      height: height,
      weight: weight,
      prePregnancyWeight: prePregnancyWeight,
      age: age,
      gender: gender,
      locality: locality,
      timezone: timezone,
      medicalHistory: medicalHistory,
      allergies: allergies,
      medications: medications,
      lifestyle: lifestyle,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await saveUserProfile(newProfile);
  }

  // Update specific fields
  Future<bool> updateHeight(double height) async {
    return await updateUserProfile({'height': height});
  }

  Future<bool> updateWeight(double weight) async {
    return await updateUserProfile({'weight': weight});
  }

  Future<bool> updateAge(int age) async {
    return await updateUserProfile({'age': age});
  }

  Future<bool> updateLocality(String locality) async {
    return await updateUserProfile({'locality': locality});
  }

  Future<bool> updateMedicalHistory(List<String> medicalHistory) async {
    return await updateUserProfile({'medicalHistory': medicalHistory});
  }

  Future<bool> updateAllergies(List<String> allergies) async {
    return await updateUserProfile({'allergies': allergies});
  }

  Future<bool> updateMedications(List<String> medications) async {
    return await updateUserProfile({'medications': medications});
  }

  Future<bool> updateLifestyle(Lifestyle lifestyle) async {
    return await updateUserProfile({'lifestyle': lifestyle.toJson()});
  }

  // Clear profile
  void clearProfile() {
    _profile = null;
    _clearError();
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}

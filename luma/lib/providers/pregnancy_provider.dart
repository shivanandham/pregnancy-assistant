import 'package:flutter/foundation.dart';
import '../models/pregnancy.dart';
import '../services/api_service.dart';
import '../services/device_timezone_service.dart';
import '../utils/date_utils.dart';

class PregnancyProvider with ChangeNotifier {
  Pregnancy? _pregnancy;
  bool _isLoading = false;
  String? _error;

  // Getters
  Pregnancy? get pregnancy => _pregnancy;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPregnancyData => _pregnancy != null;

  // Pregnancy calculations
  int get currentWeek {
    if (_pregnancy == null) return 0;
    return DateUtils.calculatePregnancyWeek(_pregnancy!.lastMenstrualPeriod);
  }

  int get daysUntilDueDate {
    if (_pregnancy == null) return 0;
    return DateUtils.calculateDaysUntilDueDate(_pregnancy!.dueDate);
  }

  int get currentTrimester {
    return DateUtils.getCurrentTrimester(currentWeek);
  }

  double get progressPercentage {
    if (_pregnancy == null) return 0.0;
    return DateUtils.calculateProgressPercentage(
      _pregnancy!.lastMenstrualPeriod,
      _pregnancy!.dueDate,
    );
  }

  int get weeksRemaining {
    return (40 - currentWeek).clamp(0, 40);
  }

  // Load pregnancy data
  Future<void> loadPregnancyData() async {
    _setLoading(true);
    _clearError();

    try {
      _pregnancy = await ApiService.getPregnancyData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load pregnancy data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Save pregnancy data
  Future<bool> savePregnancyData({
    required DateTime dueDate,
    required DateTime lastMenstrualPeriod,
    String? notes,
  }) async {
    
    _setLoading(true);
    _clearError();

    try {
      final pregnancy = Pregnancy(
        id: _pregnancy?.id ?? DeviceTimezoneService.now().millisecondsSinceEpoch.toString(),
        dueDate: dueDate,
        lastMenstrualPeriod: lastMenstrualPeriod,
        createdAt: _pregnancy?.createdAt ?? DeviceTimezoneService.now(),
        updatedAt: DeviceTimezoneService.now(),
        notes: notes,
      );

      final savedPregnancy = await ApiService.savePregnancyData(pregnancy);
      
      if (savedPregnancy != null) {
        _pregnancy = savedPregnancy;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to save pregnancy data');
        return false;
      }
    } catch (e) {
      print('❌ PregnancyProvider: Error saving pregnancy data: $e');
      _setError('Failed to save pregnancy data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update pregnancy data
  Future<bool> updatePregnancyData({
    DateTime? dueDate,
    DateTime? lastMenstrualPeriod,
    String? notes,
  }) async {
    if (_pregnancy == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedPregnancy = _pregnancy!.copyWith(
        dueDate: dueDate,
        lastMenstrualPeriod: lastMenstrualPeriod,
        notes: notes,
        updatedAt: DeviceTimezoneService.now(),
      );

      final savedPregnancy = await ApiService.savePregnancyData(updatedPregnancy);
      if (savedPregnancy != null) {
        _pregnancy = savedPregnancy;
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update pregnancy data');
        return false;
      }
    } catch (e) {
      _setError('Failed to update pregnancy data: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refresh() async {
    await loadPregnancyData();
  }

  // Clear pregnancy data
  void clearPregnancyData() {
    _pregnancy = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
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

  // Get pregnancy milestone info
  String getPregnancyMilestone() {
    if (_pregnancy == null) return 'No pregnancy data available';

    final week = currentWeek;
    
    if (week <= 4) {
      return 'Early pregnancy - Baby is the size of a poppy seed';
    } else if (week <= 8) {
      return 'First trimester - Baby is the size of a raspberry';
    } else if (week <= 12) {
      return 'First trimester - Baby is the size of a lime';
    } else if (week <= 16) {
      return 'Second trimester - Baby is the size of an avocado';
    } else if (week <= 20) {
      return 'Second trimester - Baby is the size of a banana';
    } else if (week <= 24) {
      return 'Second trimester - Baby is the size of an ear of corn';
    } else if (week <= 28) {
      return 'Third trimester - Baby is the size of a large eggplant';
    } else if (week <= 32) {
      return 'Third trimester - Baby is the size of a squash';
    } else if (week <= 36) {
      return 'Third trimester - Baby is the size of a head of romaine lettuce';
    } else {
      return 'Full term - Baby is ready to be born!';
    }
  }

  // Get trimester info
  String getTrimesterInfo() {
    final trimester = currentTrimester;
    
    switch (trimester) {
      case 1:
        return 'First Trimester (Weeks 1-12)\nFocus on prenatal care and managing early symptoms';
      case 2:
        return 'Second Trimester (Weeks 13-28)\nThe "golden period" - energy returns and baby grows rapidly';
      case 3:
        return 'Third Trimester (Weeks 29-40)\nFinal preparations and getting ready for birth';
      default:
        return 'Pregnancy information not available';
    }
  }

  // Get next milestone
  String getNextMilestone() {
    if (_pregnancy == null) return 'No pregnancy data available';

    final week = currentWeek;
    
    if (week < 12) {
      return 'First trimester screening (Week 12)';
    } else if (week < 20) {
      return 'Anatomy scan (Week 20)';
    } else if (week < 28) {
      return 'Glucose screening test (Week 28)';
    } else if (week < 36) {
      return 'Group B strep test (Week 36)';
    } else {
      return 'Baby is full term and ready to arrive!';
    }
  }
}

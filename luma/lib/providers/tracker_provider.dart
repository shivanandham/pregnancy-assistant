import 'package:flutter/foundation.dart';
import '../models/symptom.dart';
import '../models/appointment.dart';
import '../models/weight_entry.dart';
import '../services/api_service.dart';

class TrackerProvider with ChangeNotifier {
  // Symptoms
  List<Symptom> _symptoms = [];
  bool _isLoadingSymptoms = false;
  String? _symptomsError;

  // Appointments
  List<Appointment> _appointments = [];
  bool _isLoadingAppointments = false;
  String? _appointmentsError;

  // Weight entries
  List<WeightEntry> _weightEntries = [];
  bool _isLoadingWeight = false;
  String? _weightError;

  // Getters for symptoms
  List<Symptom> get symptoms => _symptoms;
  bool get isLoadingSymptoms => _isLoadingSymptoms;
  String? get symptomsError => _symptomsError;

  // Getters for appointments
  List<Appointment> get appointments => _appointments;
  bool get isLoadingAppointments => _isLoadingAppointments;
  String? get appointmentsError => _appointmentsError;

  // Getters for weight entries
  List<WeightEntry> get weightEntries => _weightEntries;
  bool get isLoadingWeight => _isLoadingWeight;
  String? get weightError => _weightError;

  // Computed getters
  List<Appointment> get upcomingAppointments {
    return _appointments
        .where((appointment) => appointment.isUpcoming)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get todayAppointments {
    final today = DateTime.now();
    return _appointments.where((appointment) {
      return appointment.dateTime.year == today.year &&
          appointment.dateTime.month == today.month &&
          appointment.dateTime.day == today.day;
    }).toList();
  }

  List<Symptom> get recentSymptoms {
    final recent = _symptoms.take(10).toList();
    recent.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return recent;
  }

  List<WeightEntry> get recentWeightEntries {
    final recent = _weightEntries.take(10).toList();
    recent.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return recent;
  }

  WeightEntry? get latestWeightEntry {
    if (_weightEntries.isEmpty) return null;
    return _weightEntries.reduce((a, b) => a.dateTime.isAfter(b.dateTime) ? a : b);
  }

  double? get weightGain {
    if (_weightEntries.length < 2) return null;
    
    final sortedEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    final firstWeight = sortedEntries.first.weight;
    final latestWeight = sortedEntries.last.weight;
    
    return latestWeight - firstWeight;
  }

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadSymptoms(),
      loadAppointments(),
      loadWeightEntries(),
    ]);
  }

  // Symptoms methods
  Future<void> loadSymptoms() async {
    _setLoadingSymptoms(true);
    _clearSymptomsError();

    try {
      _symptoms = await ApiService.getSymptoms();
      notifyListeners();
    } catch (e) {
      print('Error loading symptoms: $e');
      _setSymptomsError('Failed to load symptoms: $e');
    } finally {
      _setLoadingSymptoms(false);
    }
  }

  Future<bool> addSymptom(Symptom symptom) async {
    _setLoadingSymptoms(true);
    _clearSymptomsError();

    try {
      final addedSymptom = await ApiService.addSymptom(symptom);
      if (addedSymptom != null) {
        _symptoms.add(addedSymptom);
        notifyListeners();
        return true;
      } else {
        _setSymptomsError('Failed to add symptom');
        return false;
      }
    } catch (e) {
      _setSymptomsError('Failed to add symptom: $e');
      return false;
    } finally {
      _setLoadingSymptoms(false);
    }
  }

  Future<bool> deleteSymptom(String id) async {
    _setLoadingSymptoms(true);
    _clearSymptomsError();

    try {
      final success = await ApiService.deleteSymptom(id);
      if (success) {
        _symptoms.removeWhere((symptom) => symptom.id == id);
        notifyListeners();
        return true;
      } else {
        _setSymptomsError('Failed to delete symptom');
        return false;
      }
    } catch (e) {
      _setSymptomsError('Failed to delete symptom: $e');
      return false;
    } finally {
      _setLoadingSymptoms(false);
    }
  }

  // Appointments methods
  Future<void> loadAppointments() async {
    _setLoadingAppointments(true);
    _clearAppointmentsError();

    try {
      _appointments = await ApiService.getAppointments();
      notifyListeners();
    } catch (e) {
      _setAppointmentsError('Failed to load appointments: $e');
    } finally {
      _setLoadingAppointments(false);
    }
  }

  Future<bool> addAppointment(Appointment appointment) async {
    _setLoadingAppointments(true);
    _clearAppointmentsError();

    try {
      final addedAppointment = await ApiService.addAppointment(appointment);
      if (addedAppointment != null) {
        _appointments.add(addedAppointment);
        notifyListeners();
        return true;
      } else {
        _setAppointmentsError('Failed to add appointment');
        return false;
      }
    } catch (e) {
      _setAppointmentsError('Failed to add appointment: $e');
      return false;
    } finally {
      _setLoadingAppointments(false);
    }
  }

  Future<bool> updateAppointment(String id, Appointment appointment) async {
    _setLoadingAppointments(true);
    _clearAppointmentsError();

    try {
      final updatedAppointment = await ApiService.updateAppointment(id, appointment);
      if (updatedAppointment != null) {
        final index = _appointments.indexWhere((apt) => apt.id == id);
        if (index != -1) {
          _appointments[index] = updatedAppointment;
          notifyListeners();
          return true;
        }
      }
      _setAppointmentsError('Failed to update appointment');
      return false;
    } catch (e) {
      _setAppointmentsError('Failed to update appointment: $e');
      return false;
    } finally {
      _setLoadingAppointments(false);
    }
  }

  Future<bool> deleteAppointment(String id) async {
    _setLoadingAppointments(true);
    _clearAppointmentsError();

    try {
      final success = await ApiService.deleteAppointment(id);
      if (success) {
        _appointments.removeWhere((appointment) => appointment.id == id);
        notifyListeners();
        return true;
      } else {
        _setAppointmentsError('Failed to delete appointment');
        return false;
      }
    } catch (e) {
      _setAppointmentsError('Failed to delete appointment: $e');
      return false;
    } finally {
      _setLoadingAppointments(false);
    }
  }

  // Weight methods
  Future<void> loadWeightEntries() async {
    _setLoadingWeight(true);
    _clearWeightError();

    try {
      _weightEntries = await ApiService.getWeightEntries();
      notifyListeners();
    } catch (e) {
      _setWeightError('Failed to load weight entries: $e');
    } finally {
      _setLoadingWeight(false);
    }
  }

  Future<bool> addWeightEntry(WeightEntry weightEntry) async {
    _setLoadingWeight(true);
    _clearWeightError();

    try {
      final addedEntry = await ApiService.addWeightEntry(weightEntry);
      if (addedEntry != null) {
        _weightEntries.add(addedEntry);
        notifyListeners();
        return true;
      } else {
        _setWeightError('Failed to add weight entry');
        return false;
      }
    } catch (e) {
      _setWeightError('Failed to add weight entry: $e');
      return false;
    } finally {
      _setLoadingWeight(false);
    }
  }

  Future<bool> deleteWeightEntry(String id) async {
    _setLoadingWeight(true);
    _clearWeightError();

    try {
      final success = await ApiService.deleteWeightEntry(id);
      if (success) {
        _weightEntries.removeWhere((entry) => entry.id == id);
        notifyListeners();
        return true;
      } else {
        _setWeightError('Failed to delete weight entry');
        return false;
      }
    } catch (e) {
      _setWeightError('Failed to delete weight entry: $e');
      return false;
    } finally {
      _setLoadingWeight(false);
    }
  }

  // Refresh methods
  Future<void> refreshSymptoms() async {
    await loadSymptoms();
  }

  Future<void> refreshAppointments() async {
    await loadAppointments();
  }

  Future<void> refreshWeightEntries() async {
    await loadWeightEntries();
  }

  Future<void> refreshAll() async {
    await loadAllData();
  }

  // Helper methods for symptoms
  void _setLoadingSymptoms(bool loading) {
    _isLoadingSymptoms = loading;
    notifyListeners();
  }

  void _setSymptomsError(String error) {
    _symptomsError = error;
    notifyListeners();
  }

  void _clearSymptomsError() {
    _symptomsError = null;
  }

  // Helper methods for appointments
  void _setLoadingAppointments(bool loading) {
    _isLoadingAppointments = loading;
    notifyListeners();
  }

  void _setAppointmentsError(String error) {
    _appointmentsError = error;
    notifyListeners();
  }

  void _clearAppointmentsError() {
    _appointmentsError = null;
  }

  // Helper methods for weight
  void _setLoadingWeight(bool loading) {
    _isLoadingWeight = loading;
    notifyListeners();
  }

  void _setWeightError(String error) {
    _weightError = error;
    notifyListeners();
  }

  void _clearWeightError() {
    _weightError = null;
  }

  // Clear all data
  void clearAllData() {
    _symptoms.clear();
    _appointments.clear();
    _weightEntries.clear();
    _clearSymptomsError();
    _clearAppointmentsError();
    _clearWeightError();
    notifyListeners();
  }
}

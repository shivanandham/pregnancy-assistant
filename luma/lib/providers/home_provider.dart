import 'package:flutter/foundation.dart';
import '../models/home_data.dart';
import '../models/pregnancy_tip.dart';
import '../models/pregnancy_milestone.dart';
import '../models/daily_checklist.dart';
import '../services/api_service.dart';

class HomeProvider with ChangeNotifier {
  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;

  HomeData? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<PregnancyTip> get tips => _homeData?.tips ?? [];
  List<PregnancyMilestone> get currentMilestones => _homeData?.currentMilestones ?? [];
  List<PregnancyMilestone> get upcomingMilestones => _homeData?.upcomingMilestones ?? [];
  List<DailyChecklist> get checklist => _homeData?.checklist ?? [];
  Map<String, List<DailyChecklist>> get checklistByCategory => _homeData?.checklistByCategory ?? {};
  bool get hasPregnancyData => _homeData?.hasPregnancyData ?? false;
  int get currentWeek => _homeData?.currentWeek ?? 0;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final homeData = await ApiService.getHomeData();
      if (homeData != null) {
        _homeData = homeData;
      } else {
        _error = 'Failed to load home data';
      }
    } catch (e) {
      _error = 'Error loading home data: $e';
      if (kDebugMode) {
        print('❌ HomeProvider: Error loading home data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHomeData() async {
    await loadHomeData();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get tips for a specific week
  Future<List<PregnancyTip>> getTipsForWeek(int week) async {
    try {
      return await ApiService.getTipsForWeek(week);
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeProvider: Error getting tips for week $week: $e');
      }
      return [];
    }
  }

  // Get milestones for a specific week
  Future<Map<String, List<PregnancyMilestone>>> getMilestonesForWeek(int week) async {
    try {
      return await ApiService.getMilestonesForWeek(week);
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeProvider: Error getting milestones for week $week: $e');
      }
      return {'current': [], 'upcoming': [], 'recent': []};
    }
  }

  // Get checklist for a specific week
  Future<Map<String, dynamic>> getChecklistForWeek(int week) async {
    try {
      return await ApiService.getChecklistForWeek(week);
    } catch (e) {
      if (kDebugMode) {
        print('❌ HomeProvider: Error getting checklist for week $week: $e');
      }
      return {'tasks': <DailyChecklist>[], 'byCategory': <String, List<DailyChecklist>>{}};
    }
  }

}

import 'package:flutter/foundation.dart';
import '../models/home_data.dart';
import '../models/pregnancy_tip.dart';
import '../models/pregnancy_milestone.dart';
import '../models/daily_checklist.dart';
import '../services/api_service.dart';

/// HomeProvider with separate loading states for different components
/// 
/// Usage in UI:
/// ```dart
/// Consumer<HomeProvider>(
///   builder: (context, homeProvider, child) {
///     return Column(
///       children: [
///         // Tips section with individual loading state
///         if (homeProvider.isLoadingTips)
///           const CircularProgressIndicator()
///         else if (homeProvider.tipsError != null)
///           Text('Error: ${homeProvider.tipsError}')
///         else
///           TipsWidget(tips: homeProvider.tips),
///           
///         // Milestones section with individual loading state
///         if (homeProvider.isLoadingMilestones)
///           const CircularProgressIndicator()
///         else if (homeProvider.milestonesError != null)
///           Text('Error: ${homeProvider.milestonesError}')
///         else
///           MilestonesWidget(milestones: homeProvider.currentMilestones),
///           
///         // Checklist section with individual loading state
///         if (homeProvider.isLoadingChecklist)
///           const CircularProgressIndicator()
///         else if (homeProvider.checklistError != null)
///           Text('Error: ${homeProvider.checklistError}')
///         else
///           ChecklistWidget(checklist: homeProvider.checklist),
///       ],
///     );
///   },
/// )
/// ```
class HomeProvider with ChangeNotifier {
  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;
  
  // Separate loading states
  bool _isLoadingTips = false;
  bool _isLoadingMilestones = false;
  bool _isLoadingChecklist = false;
  
  // Separate error states
  String? _tipsError;
  String? _milestonesError;
  String? _checklistError;

  HomeData? get homeData => _homeData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Individual loading states
  bool get isLoadingTips => _isLoadingTips;
  bool get isLoadingMilestones => _isLoadingMilestones;
  bool get isLoadingChecklist => _isLoadingChecklist;
  
  // Individual error states
  String? get tipsError => _tipsError;
  String? get milestonesError => _milestonesError;
  String? get checklistError => _checklistError;

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
      // Get basic home data (pregnancy info and current week)
      final homeData = await ApiService.getHomeData();
      if (homeData == null) {
        _error = 'Failed to load home data';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // If no pregnancy data, just set the basic info
      if (!homeData.hasPregnancyData) {
        _homeData = homeData;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Set initial home data with empty lists immediately
      _homeData = homeData.copyWith(
        tips: [],
        currentMilestones: [],
        upcomingMilestones: [],
        checklist: [],
        checklistByCategory: {},
      );
      
      // Set main loading to false immediately after basic data is ready
      _isLoading = false;
      notifyListeners();

      // Load additional data from separate endpoints with individual loading states
      // Don't await these - let them load in background
      _loadTips();
      _loadMilestones();
      _loadChecklist();

    } catch (e) {
      _error = 'Error loading home data: $e';
      if (kDebugMode) {
        print('❌ HomeProvider: Error loading home data: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadTips() async {
    _isLoadingTips = true;
    _tipsError = null;
    notifyListeners();

    try {
      final tips = await ApiService.getCurrentWeekTips();
      _homeData = _homeData?.copyWith(tips: tips);
    } catch (e) {
      _tipsError = 'Failed to load tips: $e';
      if (kDebugMode) {
        print('❌ HomeProvider: Error loading tips: $e');
      }
    } finally {
      _isLoadingTips = false;
      notifyListeners();
    }
  }

  Future<void> _loadMilestones() async {
    _isLoadingMilestones = true;
    _milestonesError = null;
    notifyListeners();

    try {
      final milestonesData = await ApiService.getCurrentWeekMilestones();
      _homeData = _homeData?.copyWith(
        currentMilestones: milestonesData['current'] ?? [],
        upcomingMilestones: milestonesData['upcoming'] ?? [],
      );
    } catch (e) {
      _milestonesError = 'Failed to load milestones: $e';
      if (kDebugMode) {
        print('❌ HomeProvider: Error loading milestones: $e');
      }
    } finally {
      _isLoadingMilestones = false;
      notifyListeners();
    }
  }

  Future<void> _loadChecklist() async {
    _isLoadingChecklist = true;
    _checklistError = null;
    notifyListeners();

    try {
      final checklistData = await ApiService.getCurrentWeekChecklist();
      _homeData = _homeData?.copyWith(
        checklist: checklistData['tasks'] ?? [],
        checklistByCategory: checklistData['byCategory'] ?? {},
      );
    } catch (e) {
      _checklistError = 'Failed to load checklist: $e';
      if (kDebugMode) {
        print('❌ HomeProvider: Error loading checklist: $e');
      }
    } finally {
      _isLoadingChecklist = false;
      notifyListeners();
    }
  }

  Future<void> refreshHomeData() async {
    // Clear individual errors
    _tipsError = null;
    _milestonesError = null;
    _checklistError = null;
    
    // Reload all data
    await loadHomeData();
  }

  // Refresh individual components
  Future<void> refreshTips() async {
    if (_homeData == null || !_homeData!.hasPregnancyData) return;
    await _loadTips();
  }

  Future<void> refreshMilestones() async {
    if (_homeData == null || !_homeData!.hasPregnancyData) return;
    await _loadMilestones();
  }

  Future<void> refreshChecklist() async {
    if (_homeData == null || !_homeData!.hasPregnancyData) return;
    await _loadChecklist();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearTipsError() {
    _tipsError = null;
    notifyListeners();
  }

  void clearMilestonesError() {
    _milestonesError = null;
    notifyListeners();
  }

  void clearChecklistError() {
    _checklistError = null;
    notifyListeners();
  }

  void clearAllErrors() {
    _error = null;
    _tipsError = null;
    _milestonesError = null;
    _checklistError = null;
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

import 'pregnancy_tip.dart';
import 'pregnancy_milestone.dart';
import 'daily_checklist.dart';
import 'pregnancy.dart';

class HomeData {
  final bool hasPregnancyData;
  final int currentWeek;
  final Pregnancy? pregnancy;
  final List<PregnancyTip> tips;
  final List<PregnancyMilestone> currentMilestones;
  final List<PregnancyMilestone> upcomingMilestones;
  final List<DailyChecklist> checklist;
  final Map<String, List<DailyChecklist>> checklistByCategory;
  final String? message;

  HomeData({
    required this.hasPregnancyData,
    required this.currentWeek,
    this.pregnancy,
    required this.tips,
    required this.currentMilestones,
    required this.upcomingMilestones,
    required this.checklist,
    required this.checklistByCategory,
    this.message,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      hasPregnancyData: json['hasPregnancyData'] ?? false,
      currentWeek: json['currentWeek'] ?? 0,
      pregnancy: json['pregnancy'] != null ? Pregnancy.fromJson(json['pregnancy']) : null,
      tips: (json['tips'] as List<dynamic>?)
          ?.map((tip) => PregnancyTip.fromJson(tip))
          .toList() ?? [],
      currentMilestones: (json['currentMilestones'] as List<dynamic>?)
          ?.map((milestone) => PregnancyMilestone.fromJson(milestone))
          .toList() ?? [],
      upcomingMilestones: (json['upcomingMilestones'] as List<dynamic>?)
          ?.map((milestone) => PregnancyMilestone.fromJson(milestone))
          .toList() ?? [],
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((task) => DailyChecklist.fromJson(task))
          .toList() ?? [],
      checklistByCategory: _parseChecklistByCategory(json['checklistByCategory']),
      message: json['message'],
    );
  }

  static Map<String, List<DailyChecklist>> _parseChecklistByCategory(dynamic data) {
    if (data == null) return {};
    
    Map<String, List<DailyChecklist>> result = {};
    (data as Map<String, dynamic>).forEach((category, tasks) {
      result[category] = (tasks as List<dynamic>)
          .map((task) => DailyChecklist.fromJson(task))
          .toList();
    });
    
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'hasPregnancyData': hasPregnancyData,
      'currentWeek': currentWeek,
      'pregnancy': pregnancy?.toJson(),
      'tips': tips.map((tip) => tip.toJson()).toList(),
      'currentMilestones': currentMilestones.map((milestone) => milestone.toJson()).toList(),
      'upcomingMilestones': upcomingMilestones.map((milestone) => milestone.toJson()).toList(),
      'checklist': checklist.map((task) => task.toJson()).toList(),
      'checklistByCategory': checklistByCategory.map(
        (category, tasks) => MapEntry(category, tasks.map((task) => task.toJson()).toList())
      ),
      'message': message,
    };
  }

  HomeData copyWith({
    bool? hasPregnancyData,
    int? currentWeek,
    Pregnancy? pregnancy,
    List<PregnancyTip>? tips,
    List<PregnancyMilestone>? currentMilestones,
    List<PregnancyMilestone>? upcomingMilestones,
    List<DailyChecklist>? checklist,
    Map<String, List<DailyChecklist>>? checklistByCategory,
    String? message,
  }) {
    return HomeData(
      hasPregnancyData: hasPregnancyData ?? this.hasPregnancyData,
      currentWeek: currentWeek ?? this.currentWeek,
      pregnancy: pregnancy ?? this.pregnancy,
      tips: tips ?? this.tips,
      currentMilestones: currentMilestones ?? this.currentMilestones,
      upcomingMilestones: upcomingMilestones ?? this.upcomingMilestones,
      checklist: checklist ?? this.checklist,
      checklistByCategory: checklistByCategory ?? this.checklistByCategory,
      message: message ?? this.message,
    );
  }
}

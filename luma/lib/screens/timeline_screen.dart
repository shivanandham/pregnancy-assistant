import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/tracker_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as CustomDateUtils;
import '../services/device_timezone_service.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Timeline'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer2<PregnancyProvider, TrackerProvider>(
        builder: (context, pregnancyProvider, trackerProvider, child) {
          final pregnancy = pregnancyProvider.pregnancy;
          
          if (pregnancy == null) {
            return _buildNoPregnancyState();
          }

          return _buildTimeline(pregnancy, trackerProvider);
        },
      ),
    );
  }

  Widget _buildNoPregnancyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pregnant_woman,
            size: 80,
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Pregnancy Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please set up your pregnancy information first',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(pregnancy, TrackerProvider trackerProvider) {
    final currentWeek = pregnancy.currentWeek;
    final totalWeeks = 40;
    final progress = (currentWeek / totalWeeks).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(pregnancy, progress),
          const SizedBox(height: 24),
          _buildCurrentStatus(pregnancy),
          const SizedBox(height: 24),
          _buildMilestones(pregnancy),
          const SizedBox(height: 24),
          _buildRecentActivity(trackerProvider),
          const SizedBox(height: 24),
          _buildUpcomingEvents(pregnancy),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(pregnancy, double progress) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pregnancy Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Week ${pregnancy.currentWeek} of 40',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% Complete',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(pregnancy) {
    final currentWeek = pregnancy.currentWeek;
    final trimester = CustomDateUtils.DateUtils.getCurrentTrimester(currentWeek);
    final daysUntilDue = pregnancy.daysUntilDueDate;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Current Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem(
              'Trimester',
              'Trimester $trimester',
              _getTrimesterIcon(trimester),
              _getTrimesterColor(trimester),
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Days Until Due Date',
              daysUntilDue > 0 ? '$daysUntilDue days' : 'Overdue by ${-daysUntilDue} days',
              Icons.calendar_today,
              daysUntilDue > 0 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Current Time',
              _getCurrentTimeString(),
              Icons.access_time,
              AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _buildStatusItem(
              'Timezone',
              DeviceTimezoneService.getFormattedTimezoneInfo(),
              Icons.public,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMilestones(pregnancy) {
    final currentWeek = pregnancy.currentWeek;
    final milestones = _getMilestones(currentWeek);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pregnancy Milestones',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...milestones.map((milestone) => _buildMilestoneItem(milestone)),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone) {
    final isCompleted = milestone['week'] <= milestone['currentWeek'];
    final isCurrent = milestone['week'] == milestone['currentWeek'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isCurrent 
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? AppTheme.primaryColor 
                  : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : Icons.schedule,
              color: isCompleted ? Colors.white : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? AppTheme.primaryColor : null,
                  ),
                ),
                Text(
                  'Week ${milestone['week']}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Current',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(TrackerProvider trackerProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (trackerProvider.symptoms.isEmpty && 
                trackerProvider.appointments.isEmpty && 
                trackerProvider.weightEntries.isEmpty)
              Center(
                child: Text(
                  'No recent activity',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              )
            else
              Column(
                children: [
                  if (trackerProvider.symptoms.isNotEmpty)
                    _buildActivityItem(
                      'Latest Symptom',
                      trackerProvider.symptoms.last.type.toString().split('.').last,
                      trackerProvider.symptoms.last.dateTime,
                      Icons.health_and_safety,
                      Colors.red,
                    ),
                  if (trackerProvider.appointments.isNotEmpty)
                    _buildActivityItem(
                      'Next Appointment',
                      trackerProvider.appointments.first.title,
                      trackerProvider.appointments.first.dateTime,
                      Icons.calendar_today,
                      Colors.blue,
                    ),
                  if (trackerProvider.weightEntries.isNotEmpty)
                    _buildActivityItem(
                      'Latest Weight',
                      '${trackerProvider.weightEntries.last.weight} kg',
                      trackerProvider.weightEntries.last.dateTime,
                      Icons.monitor_weight,
                      Colors.green,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, DateTime dateTime, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            CustomDateUtils.DateUtils.getRelativeTime(dateTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(pregnancy) {
    final upcomingWeeks = _getUpcomingWeeks(pregnancy.currentWeek);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Upcoming Weeks',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...upcomingWeeks.map((week) => _buildUpcomingWeekItem(week)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingWeekItem(Map<String, dynamic> week) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '${week['week']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              week['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentTimeString() {
    final now = DeviceTimezoneService.now();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(now);
  }

  IconData _getTrimesterIcon(int trimester) {
    switch (trimester) {
      case 1:
        return Icons.child_care;
      case 2:
        return Icons.pregnant_woman;
      case 3:
        return Icons.baby_changing_station;
      default:
        return Icons.pregnant_woman;
    }
  }

  Color _getTrimesterColor(int trimester) {
    switch (trimester) {
      case 1:
        return Colors.pink;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return AppTheme.primaryColor;
    }
  }

  List<Map<String, dynamic>> _getMilestones(int currentWeek) {
    return [
      {
        'week': 4,
        'title': 'Positive Pregnancy Test',
        'currentWeek': currentWeek,
      },
      {
        'week': 8,
        'title': 'First Ultrasound',
        'currentWeek': currentWeek,
      },
      {
        'week': 12,
        'title': 'End of First Trimester',
        'currentWeek': currentWeek,
      },
      {
        'week': 20,
        'title': 'Anatomy Scan',
        'currentWeek': currentWeek,
      },
      {
        'week': 28,
        'title': 'Third Trimester Begins',
        'currentWeek': currentWeek,
      },
      {
        'week': 36,
        'title': 'Full Term',
        'currentWeek': currentWeek,
      },
      {
        'week': 40,
        'title': 'Due Date',
        'currentWeek': currentWeek,
      },
    ];
  }

  List<Map<String, dynamic>> _getUpcomingWeeks(int currentWeek) {
    final upcoming = <Map<String, dynamic>>[];
    
    for (int week = currentWeek + 1; week <= currentWeek + 4 && week <= 40; week++) {
      upcoming.add({
        'week': week,
        'description': _getWeekDescription(week),
      });
    }
    
    return upcoming;
  }

  String _getWeekDescription(int week) {
    if (week <= 12) {
      return 'First Trimester - Early development';
    } else if (week <= 28) {
      return 'Second Trimester - Growth and movement';
    } else {
      return 'Third Trimester - Final preparations';
    }
  }
}

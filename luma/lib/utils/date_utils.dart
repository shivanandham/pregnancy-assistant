import 'package:intl/intl.dart';
import '../services/device_timezone_service.dart';

class DateUtils {
  static const int daysInWeek = 7;
  static const int weeksInTrimester = 12;
  static const int totalPregnancyWeeks = 40;

  /// Calculate pregnancy week from last menstrual period
  static int calculatePregnancyWeek(DateTime lastMenstrualPeriod) {
    final now = DeviceTimezoneService.now();
    final daysSinceLMP = now.difference(lastMenstrualPeriod).inDays;
    return (daysSinceLMP / daysInWeek).floor() + 1;
  }

  /// Calculate days until due date
  static int calculateDaysUntilDueDate(DateTime dueDate) {
    final now = DeviceTimezoneService.now();
    return dueDate.difference(now).inDays;
  }

  /// Calculate days since last menstrual period
  static int calculateDaysSinceLMP(DateTime lastMenstrualPeriod) {
    final now = DeviceTimezoneService.now();
    return now.difference(lastMenstrualPeriod).inDays;
  }

  /// Get current trimester (1, 2, or 3)
  static int getCurrentTrimester(int currentWeek) {
    if (currentWeek <= 12) return 1;
    if (currentWeek <= 28) return 2;
    return 3;
  }

  /// Calculate progress percentage
  static double calculateProgressPercentage(DateTime lastMenstrualPeriod, DateTime dueDate) {
    final totalDays = dueDate.difference(lastMenstrualPeriod).inDays;
    final elapsedDays = DeviceTimezoneService.now().difference(lastMenstrualPeriod).inDays;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  /// Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  /// Format time for display
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DeviceTimezoneService.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DeviceTimezoneService.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isBefore(today);
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    final now = DeviceTimezoneService.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 days")
  static String getRelativeTime(DateTime date) {
    final now = DeviceTimezoneService.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }

  /// Get week day name
  static String getWeekDayName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Get month name
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  /// Get year
  static int getYear(DateTime date) {
    return date.year;
  }

  /// Create date from year, month, day
  static DateTime createDate(int year, int month, int day) {
    return DateTime(year, month, day);
  }

  /// Create date time from year, month, day, hour, minute
  static DateTime createDateTime(int year, int month, int day, int hour, int minute) {
    return DateTime(year, month, day, hour, minute);
  }

  /// Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Get end of week (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final daysToSunday = 7 - date.weekday;
    return DateTime(date.year, date.month, date.day + daysToSunday);
  }

  /// Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DeviceTimezoneService {
  static String? _deviceTimezone;
  static bool _initialized = false;

  /// Initialize timezone data and detect device timezone
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Detect device timezone
      if (Platform.isAndroid || Platform.isIOS) {
        // For mobile devices, use the system timezone
        _deviceTimezone = await _getDeviceTimezone();
      } else {
        // For other platforms, use local timezone
        _deviceTimezone = DateTime.now().timeZoneName;
      }

      if (kDebugMode) {
        print('🌍 Device timezone detected: $_deviceTimezone');
      }

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing timezone: $e');
      }
      // Fallback to UTC
      _deviceTimezone = 'UTC';
      _initialized = true;
    }
  }

  /// Get the device's timezone
  static String? get deviceTimezone => _deviceTimezone;

  /// Get current time in device timezone
  static DateTime now() {
    if (_deviceTimezone != null) {
      try {
        final timezoneName = _normalizeTimezoneName(_deviceTimezone!);
        final location = tz.getLocation(timezoneName);
        return tz.TZDateTime.now(location);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error getting timezone time: $e');
        }
      }
    }
    return DateTime.now();
  }

  /// Convert UTC time to device timezone
  static DateTime toDeviceTimezone(DateTime utcTime) {
    if (_deviceTimezone != null) {
      try {
        final timezoneName = _normalizeTimezoneName(_deviceTimezone!);
        final location = tz.getLocation(timezoneName);
        return tz.TZDateTime.from(utcTime, location);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error converting to device timezone: $e');
        }
      }
    }
    return utcTime.toLocal();
  }

  /// Convert device timezone to UTC
  static DateTime toUTC(DateTime localTime) {
    if (_deviceTimezone != null) {
      try {
        final timezoneName = _normalizeTimezoneName(_deviceTimezone!);
        final location = tz.getLocation(timezoneName);
        final tzTime = tz.TZDateTime.from(localTime, location);
        return tzTime.toUtc();
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error converting to UTC: $e');
        }
      }
    }
    return localTime.toUtc();
  }

  /// Get timezone offset string (e.g., "+05:30", "-08:00")
  static String getTimezoneOffset() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60);
    
    final sign = hours >= 0 ? '+' : '-';
    final absHours = hours.abs();
    
    return '$sign${absHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Get timezone name (e.g., "Asia/Kolkata", "America/New_York")
  static String getTimezoneName() {
    if (_deviceTimezone != null) {
      return _normalizeTimezoneName(_deviceTimezone!);
    }
    return _normalizeTimezoneName(DateTime.now().timeZoneName);
  }

  /// Get formatted timezone info
  static String getFormattedTimezoneInfo() {
    final name = getTimezoneName();
    final offset = getTimezoneOffset();
    return '$name ($offset)';
  }

  /// Private method to get device timezone (platform-specific)
  static Future<String?> _getDeviceTimezone() async {
    try {
      // For now, use the system timezone
      // In a real implementation, you might use platform channels
      // to get the exact timezone from the device
      final now = DateTime.now();
      return now.timeZoneName;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error detecting device timezone: $e');
      }
      return null;
    }
  }

  /// Check if timezone is initialized
  static bool get isInitialized => _initialized;

  /// Reset timezone service (for testing)
  static void reset() {
    _initialized = false;
    _deviceTimezone = null;
  }

  /// Normalize timezone name to valid IANA timezone identifier
  static String _normalizeTimezoneName(String timezoneName) {
    // Common timezone abbreviations to IANA timezone mappings
    final timezoneMappings = {
      'IST': 'Asia/Kolkata',        // Indian Standard Time
      'EST': 'America/New_York',    // Eastern Standard Time
      'PST': 'America/Los_Angeles', // Pacific Standard Time
      'CST': 'America/Chicago',     // Central Standard Time
      'MST': 'America/Denver',      // Mountain Standard Time
      'GMT': 'Europe/London',       // Greenwich Mean Time
      'UTC': 'UTC',                 // Coordinated Universal Time
      'JST': 'Asia/Tokyo',          // Japan Standard Time
      'CET': 'Europe/Paris',        // Central European Time
      'AEST': 'Australia/Sydney',   // Australian Eastern Standard Time
      'BST': 'Europe/London',       // British Summer Time
      'PDT': 'America/Los_Angeles', // Pacific Daylight Time
      'EDT': 'America/New_York',    // Eastern Daylight Time
      'CDT': 'America/Chicago',     // Central Daylight Time
      'MDT': 'America/Denver',      // Mountain Daylight Time
    };

    // Check if it's already a valid IANA timezone (contains '/')
    if (timezoneName.contains('/')) {
      return timezoneName;
    }

    // Check if it's a known abbreviation
    final normalized = timezoneMappings[timezoneName.toUpperCase()];
    if (normalized != null) {
      return normalized;
    }

    // If not found, return the original name (will fallback to system time)
    return timezoneName;
  }
}

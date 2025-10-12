import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isUpdateAvailable;
  final String? error;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isUpdateAvailable,
    this.error,
  });

  factory UpdateInfo.error(String error) {
    return UpdateInfo(
      version: '',
      downloadUrl: '',
      releaseNotes: '',
      isUpdateAvailable: false,
      error: error,
    );
  }
}

class UpdateService {
  static const String _githubApiBase = 'https://api.github.com';
  static const String _owner = 'shivanandham'; // Replace with your GitHub username
  static const String _repo = 'pregnancy-assistant'; // Replace with your repo name
  
  // Cache to avoid checking too frequently
  static DateTime? _lastCheck;
  static const Duration _checkInterval = Duration(hours: 24);
  static UpdateInfo? _cachedUpdateInfo;

  /// Check for updates from GitHub Releases
  static Future<UpdateInfo> checkForUpdates({bool forceCheck = false}) async {
    try {
      // Check if we should skip this check
      if (!forceCheck && _shouldSkipCheck()) {
        return _cachedUpdateInfo ?? UpdateInfo.error('No cached update info');
      }

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;
      
      debugPrint('🔍 Update check - Current version: $currentVersion+$currentBuildNumber');

      // Get latest release from GitHub
      final latestRelease = await _getLatestRelease();
      if (latestRelease == null) {
        return UpdateInfo.error('Failed to fetch latest release');
      }

      // Parse version from release tag (e.g., "v1.0.1" -> "1.0.1")
      final latestVersion = _parseVersionFromTag(latestRelease['tag_name']);
      if (latestVersion == null) {
        return UpdateInfo.error('Invalid version format in release tag');
      }
      
      debugPrint('🔍 Update check - Latest version: $latestVersion');

      // Compare versions
      // TEMPORARY: Force update check for final testing
      final fakeCurrentVersion = '1.0.0'; // Force older version for testing
      final isUpdateAvailable = _isVersionNewer(latestVersion, fakeCurrentVersion);
      debugPrint('🔍 Update check - Current version: $fakeCurrentVersion (FAKE FOR FINAL TESTING)');
      debugPrint('🔍 Update check - Latest version: $latestVersion');
      debugPrint('🔍 Update check - Update available: $isUpdateAvailable');

      // Get download URL for APK
      final downloadUrl = _getDownloadUrl(latestRelease['assets']);
      if (downloadUrl == null) {
        return UpdateInfo.error('No APK found in release assets');
      }

      final updateInfo = UpdateInfo(
        version: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: latestRelease['body'] ?? 'No release notes available',
        isUpdateAvailable: isUpdateAvailable,
      );

      // Cache the result
      _lastCheck = DateTime.now();
      _cachedUpdateInfo = updateInfo;

      return updateInfo;
    } catch (e) {
      return UpdateInfo.error('Error checking for updates: $e');
    }
  }

  /// Get latest release from GitHub API
  static Future<Map<String, dynamic>?> _getLatestRelease() async {
    try {
      final url = '$_githubApiBase/repos/$_owner/$_repo/releases/latest';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Luma-App-Update-Checker',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return null; // No releases found
      } else {
        throw Exception('GitHub API returned status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch latest release: $e');
    }
  }

  /// Parse version from git tag (e.g., "v1.0.1" -> "1.0.1")
  static String? _parseVersionFromTag(String tag) {
    // Remove 'v' prefix if present
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    
    // Validate version format (semantic versioning)
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+$');
    if (versionRegex.hasMatch(version)) {
      return version;
    }
    
    return null;
  }

  /// Compare if new version is newer than current version
  static bool _isVersionNewer(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      // Ensure both versions have 3 parts
      while (newParts.length < 3) newParts.add(0);
      while (currentParts.length < 3) currentParts.add(0);

      // Compare major, minor, patch
      for (int i = 0; i < 3; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }

      return false; // Versions are equal
    } catch (e) {
      return false; // If parsing fails, assume no update
    }
  }

  /// Get download URL for APK from release assets
  static String? _getDownloadUrl(List<dynamic> assets) {
    for (final asset in assets) {
      final name = asset['name'] as String?;
      if (name != null && name.endsWith('.apk')) {
        return asset['browser_download_url'] as String?;
      }
    }
    return null;
  }

  /// Check if we should skip this update check
  static bool _shouldSkipCheck() {
    if (_lastCheck == null) return false;
    return DateTime.now().difference(_lastCheck!) < _checkInterval;
  }

  /// Clear cache to force next check
  static void clearCache() {
    _lastCheck = null;
    _cachedUpdateInfo = null;
  }

  /// Get current app version info
  static Future<Map<String, String>> getCurrentVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'version': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
    };
  }

  /// Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

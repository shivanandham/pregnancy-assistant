import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadResult {
  final bool success;
  final String? error;
  final String? filePath;

  DownloadResult({
    required this.success,
    this.error,
    this.filePath,
  });
}

class UpdateManager {
  static const String _downloadDirectory = 'LumaUpdates';

  /// Request install permission for Android
  static Future<bool> requestInstallPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 8.0+ (API 26+), we need REQUEST_INSTALL_PACKAGES permission
      final status = await Permission.requestInstallPackages.status;
      
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.requestInstallPackages.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        // Open app settings to allow user to grant permission manually
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting install permission: $e');
      return false;
    }
  }

  /// Request storage permission for downloading files
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      // For Android 13+ (API 33+), we don't need storage permission for app-specific directories
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          return true; // No permission needed for app-specific directories
        }
      }

      // For older Android versions, request storage permission
      final status = await Permission.storage.status;
      
      if (status.isGranted) {
        return true;
      }

      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }

      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Download APK and install it
  static Future<DownloadResult> downloadAndInstall(
    String downloadUrl, {
    Function(double)? onProgress,
  }) async {
    try {
      // Request permissions
      final hasStoragePermission = await requestStoragePermission();
      if (!hasStoragePermission) {
        return DownloadResult(
          success: false,
          error: 'Storage permission denied',
        );
      }

      final hasInstallPermission = await requestInstallPermission();
      if (!hasInstallPermission) {
        return DownloadResult(
          success: false,
          error: 'Install permission denied. Please enable "Install unknown apps" in settings.',
        );
      }

      // Get download directory
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        return DownloadResult(
          success: false,
          error: 'Could not access download directory',
        );
      }

      // Create download directory if it doesn't exist
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Generate filename
      final fileName = 'luma-update-${DateTime.now().millisecondsSinceEpoch}.apk';
      final filePath = '${downloadDir.path}/$fileName';

      // Download the file
      final downloadResult = await _downloadFile(
        downloadUrl,
        filePath,
        onProgress: onProgress,
      );

      if (!downloadResult.success) {
        return downloadResult;
      }

      // Install the APK
      final installResult = await _installApk(filePath);
      if (!installResult.success) {
        return installResult;
      }

      return DownloadResult(
        success: true,
        filePath: filePath,
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        error: 'Download failed: $e',
      );
    }
  }

  /// Get the download directory
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Use external storage directory for Android
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          return Directory('${externalDir.path}/$_downloadDirectory');
        }
      }
      
      // Fallback to application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      return Directory('${appDir.path}/$_downloadDirectory');
    } catch (e) {
      debugPrint('Error getting download directory: $e');
      return null;
    }
  }

  /// Download file from URL
  static Future<DownloadResult> _downloadFile(
    String url,
    String filePath, {
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      final request = http.Request('GET', Uri.parse(url));
      
      final streamedResponse = await http.Client().send(request);
      
      if (streamedResponse.statusCode != 200) {
        return DownloadResult(
          success: false,
          error: 'Download failed with status: ${streamedResponse.statusCode}',
        );
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      int downloadedBytes = 0;

      final sink = file.openWrite();
      
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;
        
        if (onProgress != null && totalBytes > 0) {
          final progress = downloadedBytes / totalBytes;
          onProgress(progress);
        }
      }
      
      await sink.close();

      return DownloadResult(
        success: true,
        filePath: filePath,
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        error: 'Download error: $e',
      );
    }
  }

  /// Install APK file
  static Future<DownloadResult> _installApk(String filePath) async {
    try {
      if (!Platform.isAndroid) {
        return DownloadResult(
          success: false,
          error: 'APK installation is only supported on Android',
        );
      }

      final file = File(filePath);
      if (!await file.exists()) {
        return DownloadResult(
          success: false,
          error: 'APK file not found',
        );
      }

      // Launch the APK installation
      final uri = Uri.file(filePath);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return DownloadResult(success: true);
      } else {
        return DownloadResult(
          success: false,
          error: 'Could not launch APK installer',
        );
      }
    } catch (e) {
      return DownloadResult(
        success: false,
        error: 'Installation error: $e',
      );
    }
  }

  /// Clean up old APK files
  static Future<void> cleanupOldApks() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null || !await downloadDir.exists()) {
        return;
      }

      final files = downloadDir.listSync();
      final now = DateTime.now();
      
      // Delete APK files older than 7 days
      for (final file in files) {
        if (file is File && file.path.endsWith('.apk')) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          
          if (age.inDays > 7) {
            await file.delete();
            debugPrint('Deleted old APK: ${file.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old APKs: $e');
    }
  }

  /// Get available storage space
  static Future<int?> getAvailableStorageSpace() async {
    try {
      final downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) return null;

      // This is a simplified check - in a real app you might want to use
      // a more sophisticated method to check available space
      return 100 * 1024 * 1024; // Assume 100MB available (placeholder)
    } catch (e) {
      debugPrint('Error checking storage space: $e');
      return null;
    }
  }

  /// Check if device has enough storage for download
  static Future<bool> hasEnoughStorage(int requiredBytes) async {
    final availableSpace = await getAvailableStorageSpace();
    if (availableSpace == null) return true; // Assume OK if we can't check
    
    return availableSpace > requiredBytes;
  }
}


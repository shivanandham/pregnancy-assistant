import 'package:flutter/foundation.dart';

/// Single source of truth for backend URL configuration
/// Priority order:
/// 1. Build-time dart-define values (for CI/CD)
/// 2. Hardcoded constants (for local development)
class BackendConfig {
  // Default URLs (constants in config file)
  static const String devUrl = 'http://192.168.0.8:3000';
  // static const String devUrl = 'https://lumacare.in';
  static const String prodUrl = 'https://lumacare.in';

  // Build-time constants from --dart-define flags (set during CI/CD build)
  static const String _buildTimeBackendUrlDev = String.fromEnvironment(
    'BACKEND_URL_DEV',
    defaultValue: '',
  );
  static const String _buildTimeBackendUrlProd = String.fromEnvironment(
    'BACKEND_URL_PROD',
    defaultValue: '',
  );

  /// Get the backend URL based on environment
  /// Priority: Build-time define > hardcoded constant
  static String get url {
    if (kDebugMode) {
      // Development mode
      // 1. Try build-time define first
      if (_buildTimeBackendUrlDev.isNotEmpty) {
        return _buildTimeBackendUrlDev;
      }
      // 2. Fallback to default
      return devUrl;
    } else {
      // Production mode
      // 1. Try build-time define first (used in CI/CD)
      if (_buildTimeBackendUrlProd.isNotEmpty) {
        return _buildTimeBackendUrlProd;
      }
      // 2. Fallback to default
      return prodUrl;
    }
  }

  /// Check if we're in development mode
  static bool get isDevelopment => kDebugMode;

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;

  /// Get environment string for logging
  static String get environment => isDevelopment ? 'development' : 'production';
}


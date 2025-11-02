import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for backend URL configuration
/// Priority order:
/// 1. Build-time dart-define values (for CI/CD)
/// 2. .env file values (for local development)
/// 3. Hardcoded defaults (fallback)
class BackendConfig {
  // Default fallback URLs (used if .env is not loaded or value is missing)
  static const String _defaultDevUrl = 'http://192.168.0.8:3000';
  static const String _defaultProdUrl = 'https://lumacare.in';

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
  /// Priority: Build-time define > .env file > hardcoded default
  static String get url {
    if (kDebugMode) {
      // Development mode
      // 1. Try build-time define first
      if (_buildTimeBackendUrlDev.isNotEmpty) {
        return _buildTimeBackendUrlDev;
      }
      // 2. Try .env file
      if (dotenv.env['BACKEND_URL_DEV'] != null) {
        return dotenv.env['BACKEND_URL_DEV']!;
      }
      // 3. Fallback to default
      return _defaultDevUrl;
    } else {
      // Production mode
      // 1. Try build-time define first (used in CI/CD)
      if (_buildTimeBackendUrlProd.isNotEmpty) {
        return _buildTimeBackendUrlProd;
      }
      // 2. Try .env file (for local production builds)
      if (dotenv.env['BACKEND_URL_PROD'] != null) {
        return dotenv.env['BACKEND_URL_PROD']!;
      }
      // 3. Fallback to default
      return _defaultProdUrl;
    }
  }

  /// Check if we're in development mode
  static bool get isDevelopment => kDebugMode;

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;

  /// Get environment string for logging
  static String get environment => isDevelopment ? 'development' : 'production';
}


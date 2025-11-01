import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for backend URL configuration
/// Reads from .env file with fallback to hardcoded defaults
class BackendConfig {
  // Default fallback URLs (used if .env is not loaded or value is missing)
  static const String _defaultDevUrl = 'http://192.168.0.8:3000';
  static const String _defaultProdUrl = 'https://asdf.com';

  /// Get the backend URL based on environment
  /// Reads from .env file with fallback to defaults
  static String get url {
    if (kDebugMode) {
      // Development mode - try to read from env, fallback to default
      return dotenv.env['BACKEND_URL_DEV'] ?? _defaultDevUrl;
    } else {
      // Production mode - try to read from env, fallback to default
      return dotenv.env['BACKEND_URL_PROD'] ?? _defaultProdUrl;
    }
  }

  /// Check if we're in development mode
  static bool get isDevelopment => kDebugMode;

  /// Check if we're in production mode
  static bool get isProduction => kReleaseMode;

  /// Get environment string for logging
  static String get environment => isDevelopment ? 'development' : 'production';
}


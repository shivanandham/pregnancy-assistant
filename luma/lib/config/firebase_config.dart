import 'package:flutter/foundation.dart';
import 'backend_config.dart';

class FirebaseConfig {
  // Environment detection
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  
  // Firebase project configuration
  static String get projectId => isDevelopment 
    ? 'luma-pregnancy-assistant'  // Development project
    : 'luma-pregnancy-assistant-prod'; // Production project
  
  // Note: google-services.json is a secret file that should be updated manually
  // based on the environment (development vs production)
  // The file is gitignored and should be placed in android/app/google-services.json
  
  // Backend URL configuration - uses BackendConfig as single source of truth
  static String get backendUrl => BackendConfig.url;
  
  // Logging
  static void logEnvironment() {
    if (kDebugMode) {
      print('🔧 Firebase Environment: ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"}');
      print('🔧 Firebase Project ID: $projectId');
      print('🔧 Backend URL: $backendUrl');
      print('⚠️  Note: google-services.json must be manually updated for the correct environment');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend_config.dart';

class FirebaseConfig {
  // Environment detection
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  
  // Firebase project configuration
  // Reads project ID from Firebase app options (loaded from google-services.json / GoogleService-Info.plist)
  // Falls back to default if Firebase not initialized yet
  static String get projectId {
    try {
      final app = Firebase.app();
      return app.options.projectId;
    } catch (e) {
      // Firebase not initialized yet, return default
      return 'luma-pregnancy-assistant';
    }
  }
  
  // Backend URL configuration - uses BackendConfig as single source of truth
  static String get backendUrl => BackendConfig.url;
  
  // Logging
  static void logEnvironment() {
    if (kDebugMode) {
      print('🔧 Firebase Environment: ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"}');
      print('🔧 Firebase Project ID: $projectId');
      print('🔧 Backend URL: $backendUrl');
    }
  }
}

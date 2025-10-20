import 'package:flutter/foundation.dart';

class FirebaseConfig {
  // Environment detection
  static bool get isDevelopment => kDebugMode;
  static bool get isProduction => kReleaseMode;
  
  // Firebase project configuration
  static String get projectId => isDevelopment 
    ? 'luma-pregnancy-assistant'  // Development project
    : 'luma-pregnancy-assistant-prod'; // Production project
  
  // Configuration file names
  static String get androidConfigFile => isDevelopment
    ? 'google-services-dev.json'
    : 'google-services-prod.json';
    
  static String get iosConfigFile => isDevelopment
    ? 'GoogleService-Info-dev.plist'
    : 'GoogleService-Info-prod.plist';
  
  // Backend URL configuration
  static String get backendUrl => isDevelopment
    ? 'http://192.168.0.9:3000'  // Development backend
    : 'https://pregnancy-assistant-production.up.railway.app'; // Production backend
  
  // Logging
  static void logEnvironment() {
    if (kDebugMode) {
      print('🔧 Firebase Environment: ${isDevelopment ? "DEVELOPMENT" : "PRODUCTION"}');
      print('🔧 Firebase Project ID: $projectId');
      print('🔧 Backend URL: $backendUrl');
      print('🔧 Android Config: $androidConfigFile');
      print('🔧 iOS Config: $iosConfigFile');
    }
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // Check if we're in debug mode (development)
    if (kDebugMode) {
      // For development, use your computer's IP address (Android emulator can't reach localhost)
      return 'http://192.168.0.8:3000';
    } else {
      // For production, use the deployed URL
      return 'https://pregnancy-assistant-production.up.railway.app';
    }
  }
  
  static const Duration timeout = Duration(seconds: 30);
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Helper method to get environment info
  static String get environment {
    if (kDebugMode) {
      return 'development';
    } else {
      return 'production';
    }
  }
  
  // Helper method to check if we're in development
  static bool get isDevelopment => kDebugMode;
  
  // Helper method to check if we're in production
  static bool get isProduction => !kDebugMode;
}

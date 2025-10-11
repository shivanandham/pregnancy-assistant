import 'dart:io';

class ApiConfig {
  static String get baseUrl => 'https://pregnancy-assistant-production.up.railway.app';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

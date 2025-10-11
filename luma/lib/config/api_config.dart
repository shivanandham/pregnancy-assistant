import 'dart:io';

class ApiConfig {
  static String get baseUrl => Platform.isAndroid 
    ? 'http://10.0.2.2:3000'
    : 'http://localhost:3000';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

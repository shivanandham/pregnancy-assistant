import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

/// Custom HTTP client that automatically adds authentication headers
class AuthenticatedHttpClient {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration timeout = ApiConfig.timeout;
  static bool _isHandlingUnauthorized = false;
  
  /// Get headers with authentication token
  static Future<Map<String, String>> getHeaders() async {
    try {
      final sessionToken = await AuthService.getIdToken();
      if (sessionToken != null) {
        return {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $sessionToken',
        };
      }
    } catch (e) {
      print('Error getting auth headers: $e');
    }
    return ApiConfig.headers;
  }
  
  /// Handle 401 response - check for revoked session and logout
  static Future<bool> _handleUnauthorized(http.Response response) async {
    if (response.statusCode != 401) {
      return false;
    }
    
    // Prevent multiple simultaneous handlers
    if (_isHandlingUnauthorized) {
      return false;
    }
    
    _isHandlingUnauthorized = true;
    
    try {
      // Parse response to check for revoked session
      bool isRevoked = false;
      try {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] as String?;
        
        if (message != null) {
          final lowerMessage = message.toLowerCase();
          if (lowerMessage.contains('revoked') || lowerMessage.contains('session expired')) {
            isRevoked = true;
          }
        }
      } catch (e) {
        // Check raw body if JSON parsing fails
        final bodyStr = response.body.toString().toLowerCase();
        if (bodyStr.contains('revoked') || bodyStr.contains('session expired')) {
          isRevoked = true;
        }
      }
      
      // If session is revoked, logout immediately
      if (isRevoked) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Force logout even if signOut fails
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('session_token');
            await prefs.remove('refresh_token');
            await prefs.remove('token_expires_at');
            await prefs.remove('refresh_expires_at');
            final auth = FirebaseAuth.instance;
            await auth.signOut();
          } catch (e2) {
            // Ignore force logout errors
          }
        }
        return false;
      }
      
      // Check if we have a refresh token
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) {
        return false;
      }
      
      // Try to refresh token
      final refreshed = await AuthService.refreshSessionToken();
      
      if (!refreshed) {
        return false;
      }
      
      return true;
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
  
  /// GET request with automatic authentication and token refresh
  static Future<http.Response> get(String endpoint) async {
    var headers = await getHeaders();
    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
    
    // Handle 401 - check for revoked, try refresh, or logout
    if (response.statusCode == 401) {
      final shouldRetry = await _handleUnauthorized(response);
      
      if (shouldRetry) {
        // Retry with new token
        headers = await getHeaders();
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        ).timeout(timeout);
      }
      
      // If still 401 after retry, logout
      if (response.statusCode == 401) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Ignore logout errors
        }
      }
    }
    
    return response;
  }
  
  /// POST request with automatic authentication and token refresh
  static Future<http.Response> post(String endpoint, {Object? body}) async {
    var headers = await getHeaders();
    var response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
    
    if (response.statusCode == 401) {
      final shouldRetry = await _handleUnauthorized(response);
      
      if (shouldRetry) {
        headers = await getHeaders();
        response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout);
      }
      
      if (response.statusCode == 401) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Ignore logout errors
        }
      }
    }
    
    return response;
  }
  
  /// PUT request with automatic authentication and token refresh
  static Future<http.Response> put(String endpoint, {Object? body}) async {
    var headers = await getHeaders();
    var response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
    
    if (response.statusCode == 401) {
      final shouldRetry = await _handleUnauthorized(response);
      
      if (shouldRetry) {
        headers = await getHeaders();
        response = await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout);
      }
      
      if (response.statusCode == 401) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Ignore logout errors
        }
      }
    }
    
    return response;
  }
  
  /// PATCH request with automatic authentication and token refresh
  static Future<http.Response> patch(String endpoint, {Object? body}) async {
    var headers = await getHeaders();
    var response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
    
    if (response.statusCode == 401) {
      final shouldRetry = await _handleUnauthorized(response);
      
      if (shouldRetry) {
        headers = await getHeaders();
        response = await http.patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout);
      }
      
      if (response.statusCode == 401) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Ignore logout errors
        }
      }
    }
    
    return response;
  }
  
  /// DELETE request with automatic authentication and token refresh
  static Future<http.Response> delete(String endpoint) async {
    var headers = await getHeaders();
    var response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
    
    if (response.statusCode == 401) {
      final shouldRetry = await _handleUnauthorized(response);
      
      if (shouldRetry) {
        headers = await getHeaders();
        response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        ).timeout(timeout);
      }
      
      if (response.statusCode == 401) {
        try {
          await AuthService.signOut();
        } catch (e) {
          // Ignore logout errors
        }
      }
    }
    
    return response;
  }
  
  /// Health check (no auth required)
  static Future<http.Response> healthCheck() async {
    return await http.get(
      Uri.parse('$baseUrl/health'),
    ).timeout(timeout);
  }
}

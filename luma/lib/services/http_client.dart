import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

/// Custom HTTP client that automatically adds authentication headers
class AuthenticatedHttpClient {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration timeout = ApiConfig.timeout;

  /// Get headers with automatic authentication
  static Future<Map<String, String>> getHeaders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        return {
          ...ApiConfig.headers,
          'Authorization': 'Bearer $idToken',
        };
      }
    } catch (e) {
      print('Error getting auth headers: $e');
    }
    return ApiConfig.headers;
  }

  /// GET request with automatic authentication
  static Future<http.Response> get(String endpoint) async {
    final headers = await getHeaders();
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
  }

  /// POST request with automatic authentication
  static Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await getHeaders();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// PUT request with automatic authentication
  static Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await getHeaders();
    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// PATCH request with automatic authentication
  static Future<http.Response> patch(String endpoint, {Object? body}) async {
    final headers = await getHeaders();
    return await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(timeout);
  }

  /// DELETE request with automatic authentication
  static Future<http.Response> delete(String endpoint) async {
    final headers = await getHeaders();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(timeout);
  }

  /// Health check (no auth required)
  static Future<http.Response> healthCheck() async {
    return await http.get(
      Uri.parse('$baseUrl/health'),
      headers: ApiConfig.headers,
    ).timeout(timeout);
  }
}

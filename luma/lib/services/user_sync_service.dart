import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class UserSyncService {
  static String get _backendUrl => FirebaseConfig.backendUrl;

  /// Sync user data with backend database
  /// This ensures the user exists in our PostgreSQL database
  static Future<Map<String, dynamic>> syncUser(User user) async {
    try {
      print('🔄 Syncing user with backend: ${user.uid}');
      
      // Get ID token for authentication
      final idToken = await user.getIdToken();
      
      // Prepare user data
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
      
      // Call backend sync endpoint
      final response = await http.post(
        Uri.parse('$_backendUrl/api/auth/sync'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ User synced successfully: ${responseData['data']['id']}');
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        print('❌ User sync failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error': 'Sync failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error syncing user: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if user is synced with backend
  static Future<bool> isUserSynced(User user) async {
    try {
      final idToken = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/account'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error checking user sync status: $e');
      return false;
    }
  }

  /// Get user account details from backend
  static Future<Map<String, dynamic>?> getUserAccount(User user) async {
    try {
      final idToken = await user.getIdToken();
      
      final response = await http.get(
        Uri.parse('$_backendUrl/api/auth/account'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data'];
      } else {
        print('❌ Failed to get user account: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting user account: $e');
      return null;
    }
  }
}

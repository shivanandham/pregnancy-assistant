import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class TestAuthService {
  static String get _backendUrl => FirebaseConfig.backendUrl;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configure Google Sign-In with Web Client ID from google-services.json
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Test Google Sign-in and backend integration
  Future<Map<String, dynamic>> testGoogleSignIn() async {
    try {
      FirebaseConfig.logEnvironment();
      print('🔧 Testing Google Sign-in...');
      
      // Step 1: Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'Google Sign-in cancelled by user'
        };
      }

      print('✅ Google Sign-in successful: ${googleUser.email}');

      // Step 2: Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 3: Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return {
          'success': false,
          'message': 'Firebase authentication failed'
        };
      }

      print('✅ Firebase authentication successful: ${user.uid}');

      // Step 4: Get ID token for backend
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        return {
          'success': false,
          'message': 'Failed to get ID token'
        };
      }

      print('✅ ID Token obtained: ${idToken.substring(0, 50)}...');

      // Step 5: Test backend authentication
      final backendResult = await _testBackendAuth(idToken, user);
      
      return {
        'success': true,
        'message': 'Google Sign-in test completed successfully',
        'user': {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        },
        'backend': backendResult,
      };

    } catch (error) {
      print('❌ Google Sign-in test failed: $error');
      return {
        'success': false,
        'message': 'Google Sign-in test failed: $error'
      };
    }
  }

  /// Test backend authentication with ID token
  Future<Map<String, dynamic>> _testBackendAuth(String idToken, User user) async {
    try {
      print('🔧 Testing backend authentication...');

      // Test 1: Sync user with backend
      final syncResponse = await http.post(
        Uri.parse('$_backendUrl/api/auth/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        }),
      );

      print('📤 Sync response: ${syncResponse.statusCode}');
      final syncData = jsonDecode(syncResponse.body);
      print('📊 Sync data: $syncData');

      if (syncResponse.statusCode != 200) {
        return {
          'success': false,
          'message': 'Backend sync failed: ${syncData['message']}'
        };
      }

      // Test 2: Test protected endpoint
      final protectedResponse = await http.get(
        Uri.parse('$_backendUrl/api/pregnancy'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );

      print('📤 Protected endpoint response: ${protectedResponse.statusCode}');
      final protectedData = jsonDecode(protectedResponse.body);
      print('📊 Protected data: $protectedData');

      return {
        'success': true,
        'message': 'Backend authentication successful',
        'sync': syncData,
        'protectedEndpoint': protectedData,
      };

    } catch (error) {
      print('❌ Backend authentication test failed: $error');
      return {
        'success': false,
        'message': 'Backend authentication test failed: $error'
      };
    }
  }

  /// Test creating pregnancy data
  Future<Map<String, dynamic>> testCreatePregnancyData(String idToken) async {
    try {
      print('🔧 Testing pregnancy data creation...');

      final response = await http.post(
        Uri.parse('$_backendUrl/api/pregnancy'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'dueDate': '2024-08-15T00:00:00.000Z',
          'lastMenstrualPeriod': '2023-11-08T00:00:00.000Z',
          'notes': 'Test pregnancy data from Flutter app',
        }),
      );

      print('📤 Pregnancy data response: ${response.statusCode}');
      final data = jsonDecode(response.body);
      print('📊 Pregnancy data: $data');

      return {
        'success': response.statusCode == 200,
        'message': response.statusCode == 200 ? 'Pregnancy data created successfully' : 'Failed to create pregnancy data',
        'data': data,
      };

    } catch (error) {
      print('❌ Pregnancy data creation test failed: $error');
      return {
        'success': false,
        'message': 'Pregnancy data creation test failed: $error'
      };
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    print('✅ Signed out successfully');
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Current user
  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => _auth.currentUser != null;
  
  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }
      
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Send user data to backend for registration/login
      await _syncUserWithBackend(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  /// Sign out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
  
  /// Get ID token for API authentication
  static Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting ID token: $e');
      return null;
    }
  }
  
  /// Sync user data with backend
  static Future<void> _syncUserWithBackend(User user) async {
    try {
      final idToken = await user.getIdToken();
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/sync'),
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
      
      if (response.statusCode != 200) {
        print('Failed to sync user with backend: ${response.statusCode}');
      }
    } catch (e) {
      print('Error syncing user with backend: $e');
    }
  }
  
  /// Get user profile from backend
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final idToken = await getIdToken();
      if (idToken == null) return null;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/profile'),
        headers: {
          'Authorization': 'Bearer $idToken',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}

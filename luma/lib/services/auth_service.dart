import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configure Google Sign-In with Web Client ID from google-services.json
  // Web Client ID: 607143667861-9j0e1tf0vj3qjb6v65rltr9i7qd1vuk5.apps.googleusercontent.com
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  // Storage keys
  static const String _sessionTokenKey = 'session_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _refreshExpiresAtKey = 'refresh_expires_at';
  
  // Lock to prevent concurrent login attempts
  static Completer<void>? _loginInProgress;
  static bool _isLoggingOut = false;
  
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
      
      // Get Firebase ID token and login to backend for session token
      final firebaseToken = await userCredential.user!.getIdToken();
      if (firebaseToken != null) {
        await _loginToBackend(firebaseToken, userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }
  
  /// Sign out - clears everything and signs out from Firebase
  static Future<void> signOut() async {
    if (_isLoggingOut) {
      return;
    }
    
    _isLoggingOut = true;
    
    try {
      // Get session token BEFORE clearing (needed for authenticated logout)
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString(_sessionTokenKey);
      
      // Call backend logout FIRST (requires authentication) - this revokes the session
      if (sessionToken != null) {
        try {
          await http.post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $sessionToken',
            },
          ).timeout(const Duration(seconds: 2));
        } catch (e) {
          // May fail if session already revoked or network error - that's okay
        }
      }
      
      // Clear tokens AFTER backend logout
      await _clearTokens();
      
      // Sign out from Firebase - this MUST trigger auth state change
      try {
        await _auth.signOut();
      } catch (e) {
        // Continue even if Firebase signout fails
      }
      
      // Sign out from Google
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        // Continue even if Google signout fails
      }
      
      // Give auth state change time to propagate
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      // Ensure Firebase logout happens even on error
      try {
        await _clearTokens();
        await _auth.signOut();
        await _googleSignIn.signOut();
      } catch (e2) {
        // Ignore cleanup errors
      }
    } finally {
      // Reset flag after delay
      Future.delayed(const Duration(seconds: 1), () {
        _isLoggingOut = false;
      });
    }
  }
  
  /// Get session token - prevents concurrent logins
  static Future<String?> getIdToken() async {
    // Don't try to get token if logging out
    if (_isLoggingOut) {
      return null;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      var sessionToken = prefs.getString(_sessionTokenKey);
      
      // Check if token is expired first (before trying to create new one)
      if (sessionToken != null) {
        final expiresAtStr = prefs.getString(_tokenExpiresAtKey);
        if (expiresAtStr != null) {
          final expiresAt = DateTime.parse(expiresAtStr);
          if (DateTime.now().isAfter(expiresAt)) {
            // Token expired, try to refresh
            final refreshed = await refreshSessionToken();
            if (refreshed) {
              return prefs.getString(_sessionTokenKey);
            }
            // Refresh failed - don't create new session, let 401 handler deal with logout
            return null;
          }
        }
        return sessionToken;
      }
      
      // No session token - handle different scenarios:
      // 1. Fresh login (after app restart) - Firebase signed in, no tokens stored yet
      // 2. Expired session - tokens were cleared due to expiration
      // 
      // We can distinguish by checking if this is immediately after Firebase sign-in
      // For now, only auto-login if Firebase user exists and no tokens (fresh login scenario)
      // But this should ideally only happen in signInWithGoogle(), not getIdToken()
      //
      // TODO: Consider moving auto-login to AuthProvider initialization instead of getIdToken()
      if (sessionToken == null && _auth.currentUser != null) {
        // Wait for any in-progress login
        if (_loginInProgress != null) {
          await _loginInProgress!.future;
          // Re-check token after waiting
          sessionToken = prefs.getString(_sessionTokenKey);
          if (sessionToken != null) {
            return sessionToken;
          }
        } else {
          // Check if we have any token metadata (expiresAt) to determine if this was a cleared session
          final hadTokens = prefs.getString(_tokenExpiresAtKey) != null || 
                           prefs.getString(_refreshExpiresAtKey) != null;
          
          if (hadTokens) {
            // We had tokens before but they're missing now - likely expired and cleared
            // Don't auto-create new session, return null and let 401 handler logout
            return null;
          }
          
          // No tokens at all - this is a fresh login scenario (after app restart)
          // Auto-login to restore session
          final completer = Completer<void>();
          _loginInProgress = completer;
          
          try {
            final firebaseToken = await _auth.currentUser!.getIdToken();
            if (firebaseToken != null) {
              await _loginToBackend(firebaseToken, _auth.currentUser!);
              sessionToken = prefs.getString(_sessionTokenKey);
            }
          } catch (e) {
            // Failed to get session token
          } finally {
            _loginInProgress?.complete();
            _loginInProgress = null;
          }
        }
        
        return prefs.getString(_sessionTokenKey);
      }
      
      return null;
    } catch (e) {
      print('Error getting session token: $e');
      return null;
    }
  }
  
  /// Refresh session token
  static Future<bool> refreshSessionToken() async {
    if (_isLoggingOut) {
      return false;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) {
        return false;
      }
      
      // Check if refresh token is expired
      final refreshExpiresAtStr = prefs.getString(_refreshExpiresAtKey);
      if (refreshExpiresAtStr != null) {
        final refreshExpiresAt = DateTime.parse(refreshExpiresAtStr);
        if (DateTime.now().isAfter(refreshExpiresAt)) {
          await _clearTokens();
          // Both tokens expired - logout user
          await signOut();
          return false;
        }
      }
      
      // Call refresh endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          await _storeTokens(
            data['sessionToken'],
            data['refreshToken'],
            DateTime.parse(data['expiresAt']),
            DateTime.parse(data['refreshExpiresAt']),
          );
          return true;
        }
      }
      
      // If refresh fails with 401, check if session is revoked
      if (response.statusCode == 401) {
        try {
          final responseData = jsonDecode(response.body);
          final message = responseData['message'] as String?;
          
          if (message != null && 
              (message.toLowerCase().contains('revoked') || 
               message.toLowerCase().contains('session expired'))) {
            await signOut();
            return false;
          }
        } catch (e) {
          // Can't parse response
        }
        
        // Clear tokens on any 401
        await _clearTokens();
      }
      
      return false;
    } catch (e) {
      print('Error refreshing session token: $e');
      return false;
    }
  }
  
  /// Login to backend with Firebase token
  static Future<void> _loginToBackend(String firebaseToken, User user) async {
    try {
      final deviceInfo = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'firebaseToken': firebaseToken,
          'deviceInfo': deviceInfo,
        }),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final data = responseData['data'];
          await _storeTokens(
            data['sessionToken'],
            data['refreshToken'],
            DateTime.parse(data['expiresAt']),
            DateTime.parse(data['refreshExpiresAt']),
          );
        } else {
          throw Exception(responseData['message'] ?? 'Login failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Error logging in to backend: $e');
      rethrow;
    }
  }
  
  /// Store tokens in shared preferences
  static Future<void> _storeTokens(
    String sessionToken,
    String refreshToken,
    DateTime expiresAt,
    DateTime refreshExpiresAt,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionTokenKey, sessionToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_tokenExpiresAtKey, expiresAt.toIso8601String());
    await prefs.setString(_refreshExpiresAtKey, refreshExpiresAt.toIso8601String());
  }
  
  /// Clear stored tokens
  static Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiresAtKey);
    await prefs.remove(_refreshExpiresAtKey);
  }
}

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_sync_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  bool _isSynced = false;
  Map<String, dynamic>? _userAccount;
  
  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSignedIn => _user != null;
  bool get isInitialized => _isInitialized;
  bool get isSynced => _isSynced;
  Map<String, dynamic>? get userAccount => _userAccount;
  
  // User info getters
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoURL => _user?.photoURL;
  
  AuthProvider() {
    _initialize();
  }
  
  /// Initialize auth state listener
  void _initialize() {
    AuthService.authStateChanges.listen((User? user) async {
      _user = user;
      _isInitialized = true;
      
      if (user != null) {
        // User is signed in, sync with backend
        await _syncUserWithBackend(user);
      } else {
        // User signed out, reset sync state
        _isSynced = false;
        _userAccount = null;
      }
      
      notifyListeners();
    });
  }
  
  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    
    try {
      final userCredential = await AuthService.signInWithGoogle();
      if (userCredential != null) {
        _user = userCredential.user;
        
        // Sync user with backend after successful sign in
        if (_user != null) {
          await _syncUserWithBackend(_user!);
        }
        
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Sign in failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await AuthService.signOut();
      _user = null;
      _isSynced = false;
      _userAccount = null;
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Get ID token for API calls
  Future<String?> getIdToken() async {
    try {
      return await AuthService.getIdToken();
    } catch (e) {
      _setError('Failed to get authentication token: $e');
      return null;
    }
  }
  
  /// Get user profile from backend
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (profile != null) {
        return {
          'id': profile.id,
          'height': profile.height,
          'weight': profile.weight,
          'prePregnancyWeight': profile.prePregnancyWeight,
          'age': profile.age,
          'gender': profile.gender,
          'locality': profile.locality,
          'medicalHistory': profile.medicalHistory,
          'allergies': profile.allergies,
          'medications': profile.medications,
          'timezone': profile.timezone,
          'lifestyle': profile.lifestyle != null ? {
            'diet': profile.lifestyle!.diet,
            'exercise': profile.lifestyle!.exercise,
            'smoking': profile.lifestyle!.smoking,
          } : null,
        };
      }
      return null;
    } catch (e) {
      _setError('Failed to get user profile: $e');
      return null;
    }
  }

  /// Sync user with backend (internal method)
  Future<void> _syncUserWithBackend(User user) async {
    try {
      final result = await UserSyncService.syncUser(user);
      
      if (result['success']) {
        _isSynced = true;
        _userAccount = result['data'];
      } else {
        _isSynced = false;
        _setError('Failed to sync user: ${result['error']}');
      }
    } catch (e) {
      _isSynced = false;
      _setError('Error syncing user: $e');
    }
  }

  /// Manually sync user with backend
  Future<bool> syncUser() async {
    if (_user == null) {
      _setError('No user signed in');
      return false;
    }

    _setLoading(true);
    _clearError();
    
    try {
      await _syncUserWithBackend(_user!);
      return _isSynced;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user is synced with backend
  Future<bool> checkSyncStatus() async {
    if (_user == null) {
      return false;
    }

    try {
      final isSynced = await UserSyncService.isUserSynced(_user!);
      _isSynced = isSynced;
      notifyListeners();
      return isSynced;
    } catch (e) {
      return false;
    }
  }

  /// Get user account details from backend
  Future<Map<String, dynamic>?> getUserAccount() async {
    if (_user == null) {
      return null;
    }

    try {
      final account = await UserSyncService.getUserAccount(_user!);
      if (account != null) {
        _userAccount = account;
        notifyListeners();
      }
      return account;
    } catch (e) {
      return null;
    }
  }
  
  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/pregnancy_provider.dart';
import 'providers/tracker_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/chat_session_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/home_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/test_auth_screen.dart';
import 'services/device_timezone_service.dart';
import 'services/update_service.dart';
import 'widgets/update_dialog.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Log environment configuration
  FirebaseConfig.logEnvironment();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize device timezone service
  await DeviceTimezoneService.initialize();
  
  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PregnancyProvider()),
        ChangeNotifierProvider(create: (_) => TrackerProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ChatSessionProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
      ],
      child: MaterialApp(
        title: 'Luma - Pregnancy Assistant',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const AppWithUpdateCheck(),
          '/test-auth': (context) => const TestAuthScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (!authProvider.isInitialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing...'),
                ],
              ),
            ),
          );
        }
        
        // Show login screen if not authenticated
        if (!authProvider.isSignedIn) {
          return const LoginScreen();
        }
        
        // Show sync loading screen if user is signed in but not synced
        if (authProvider.isSignedIn && !authProvider.isSynced && !authProvider.isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Syncing with server...'),
                  const SizedBox(height: 8),
                  Text(
                    'User: ${authProvider.userDisplayName ?? authProvider.userEmail}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show main app if authenticated and synced
        return const AppWithUpdateCheck();
      },
    );
  }
}

class AppWithUpdateCheck extends StatefulWidget {
  const AppWithUpdateCheck({super.key});

  @override
  State<AppWithUpdateCheck> createState() => _AppWithUpdateCheckState();
}

class _AppWithUpdateCheckState extends State<AppWithUpdateCheck> {
  bool _hasCheckedForUpdates = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdatesAfterDelay();
  }

  Future<void> _checkForUpdatesAfterDelay() async {
    // Wait 2 seconds after app startup before checking for updates
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted && !_hasCheckedForUpdates) {
      _hasCheckedForUpdates = true;
      await _checkForUpdates();
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      debugPrint('🔄 Starting update check...');
      
      // Check internet connection first
      final hasInternet = await UpdateService.hasInternetConnection();
      if (!hasInternet) {
        debugPrint('❌ No internet connection, skipping update check');
        return;
      }
      debugPrint('✅ Internet connection available');

      // Check for updates
      debugPrint('🔍 Checking for updates...');
      final updateInfo = await UpdateService.checkForUpdates();
      
      debugPrint('📋 Update info: available=${updateInfo.isUpdateAvailable}, error=${updateInfo.error}');
      
      if (updateInfo.isUpdateAvailable && mounted) {
        debugPrint('🎯 Showing update dialog');
        _showUpdateDialog(updateInfo);
      } else {
        debugPrint('ℹ️ No update available or dialog not shown');
      }
    } catch (e) {
      debugPrint('❌ Error checking for updates: $e');
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(updateInfo: updateInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}
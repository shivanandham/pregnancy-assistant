import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pregnancy_provider.dart';
import 'providers/tracker_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/chat_session_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/home_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation.dart';
import 'services/device_timezone_service.dart';
import 'services/update_service.dart';
import 'widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        home: const AppWithUpdateCheck(),
      ),
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
      // Check internet connection first
      final hasInternet = await UpdateService.hasInternetConnection();
      if (!hasInternet) {
        debugPrint('No internet connection, skipping update check');
        return;
      }

      // Check for updates
      final updateInfo = await UpdateService.checkForUpdates();
      
      if (updateInfo.isUpdateAvailable && mounted) {
        _showUpdateDialog(updateInfo);
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
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
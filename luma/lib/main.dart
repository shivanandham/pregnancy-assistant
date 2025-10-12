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
        home: const MainNavigation(),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'tracker_screen.dart';
import 'chatbot_screen.dart';
import 'calendar_screen.dart';
import 'user_profile_screen.dart';
import 'debug_screen.dart';
import '../theme/app_theme.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/tracker_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_session_provider.dart';
import '../providers/user_profile_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _callbacksSetup = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrackerScreen(),
    const ChatbotScreen(),
    const CalendarScreen(),
    const UserProfileScreen(),
    if (kDebugMode) const DebugScreen(), // Only show in debug mode
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _setupProviderCallbacks() {
    // Set up callback for ChatSessionProvider to notify ChatProvider
    try {
      final sessionProvider = context.read<ChatSessionProvider>();
      final chatProvider = context.read<ChatProvider>();
      
      sessionProvider.onSessionChanged = (sessionId) {
        if (sessionId.isEmpty) {
          // New session - clear messages
          chatProvider.clearMessages();
        } else {
          // Existing session - load messages
          chatProvider.loadSessionMessages(sessionId);
        }
      };
      
      // Set up callback for ChatProvider to notify ChatSessionProvider when session is updated
      chatProvider.onSessionUpdated = () {
        sessionProvider.loadSessions();
      };
    } catch (e) {
      print('❌ MainNavigation: Error setting up callbacks: $e');
    }
  }

  Future<void> _loadInitialData() async {
    
    // Load pregnancy data
    await context.read<PregnancyProvider>().loadPregnancyData();
    
    // Load tracker data
    await context.read<TrackerProvider>().loadAllData();
    
    // Load chat sessions first
    await context.read<ChatSessionProvider>().loadSessions();
    
    // Load user profile
    await context.read<UserProfileProvider>().loadUserProfile();
    
  }

  @override
  Widget build(BuildContext context) {
    // Set up callbacks once when the widget is built
    if (!_callbacksSetup) {
      _setupProviderCallbacks();
      _callbacksSetup = true;
    }
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.surfaceColor,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_outlined),
              activeIcon: Icon(Icons.track_changes),
              label: 'Tracker',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Assistant',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            if (kDebugMode)
              const BottomNavigationBarItem(
                icon: Icon(Icons.bug_report_outlined),
                activeIcon: Icon(Icons.bug_report),
                label: 'Debug',
              ),
          ],
        ),
      ),
    );
  }
}

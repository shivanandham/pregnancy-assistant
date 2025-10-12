import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'tracker_screen.dart';
import 'chatbot_screen.dart';
import 'calendar_screen.dart';
import 'user_profile_screen.dart';
import 'timeline_screen.dart';
import 'debug_screen.dart';
import '../theme/app_theme.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/tracker_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_session_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/home_provider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _callbacksSetup = false;
  List<int> _navigationHistory = [0]; // Track navigation history

  final List<Widget> _screens = [
    const HomeScreen(),
    const TrackerScreen(),
    const ChatbotScreen(),
    const CalendarScreen(),
    const TimelineScreen(),
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
    if (!mounted) return;
    
    // Load pregnancy data
    await context.read<PregnancyProvider>().loadPregnancyData();
    if (!mounted) return;
    
    // Load home data
    await context.read<HomeProvider>().loadHomeData();
    if (!mounted) return;
    
    // Load tracker data
    await context.read<TrackerProvider>().loadAllData();
    if (!mounted) return;
    
    // Load chat sessions first
    await context.read<ChatSessionProvider>().loadSessions();
    if (!mounted) return;
    
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
    
    return PopScope(
      canPop: false, // Prevent default back button behavior
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              // Only add to history if it's different from current index
              if (index != _currentIndex) {
                _navigationHistory.add(index);
                // Keep history limited to prevent memory issues
                if (_navigationHistory.length > 10) {
                  _navigationHistory.removeAt(0);
                }
              }
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
              icon: Icon(Icons.timeline_outlined),
              activeIcon: Icon(Icons.timeline),
              label: 'Timeline',
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
      ),
    );
  }

  void _handleBackButton() {
    // If we have navigation history, go back to previous screen
    if (_navigationHistory.length > 1) {
      setState(() {
        _navigationHistory.removeLast(); // Remove current screen
        _currentIndex = _navigationHistory.last; // Go to previous screen
      });
    } else {
      // If we're on the home screen or no history, show exit confirmation
      _showExitConfirmation();
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                SystemNavigator.pop(); // Exit the app
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }

}

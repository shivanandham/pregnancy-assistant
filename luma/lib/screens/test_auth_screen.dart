import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/test_auth_service.dart';
import '../providers/auth_provider.dart';

class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final TestAuthService _authService = TestAuthService();
  bool _isLoading = false;
  String _testResults = '';
  Map<String, dynamic>? _userInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Test'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            if (_userInfo != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ User Signed In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${_userInfo!['email']}'),
                      Text('Name: ${_userInfo!['displayName']}'),
                      Text('UID: ${_userInfo!['uid']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGoogleSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Test Google Sign-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            if (_authService.isSignedIn) ...[
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testCreatePregnancyData,
                icon: const Icon(Icons.pregnant_woman),
                label: const Text('Test Create Pregnancy Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: _isLoading ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Testing authentication...'),
                  ],
                ),
              ),

            // Auth Status
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isSignedIn) {
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: authProvider.isSynced ? Colors.green.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: authProvider.isSynced ? Colors.green.shade300 : Colors.orange.shade300,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  authProvider.isSynced ? Icons.check_circle : Icons.sync,
                                  color: authProvider.isSynced ? Colors.green : Colors.orange,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  authProvider.isSynced ? 'User Synced' : 'Syncing...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: authProvider.isSynced ? Colors.green.shade700 : Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('User: ${authProvider.userDisplayName ?? authProvider.userEmail}'),
                            if (authProvider.userAccount != null) ...[
                              Text('Database ID: ${authProvider.userAccount!['id']}'),
                              Text('Has Profile: ${authProvider.userAccount!['hasProfile']}'),
                              Text('Has Pregnancy Data: ${authProvider.userAccount!['hasPregnancyData']}'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Test Results
            if (_testResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Test Results:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _testResults,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _testResults = '';
      _userInfo = null;
    });

    try {
      final result = await _authService.testGoogleSignIn();
      
      setState(() {
        _testResults = _formatTestResults(result);
        if (result['success'] && result['user'] != null) {
          _userInfo = result['user'];
        }
      });

      // Show result in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] ? '✅ Test Passed!' : '❌ Test Failed'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

    } catch (error) {
      setState(() {
        _testResults = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreatePregnancyData() async {
    if (!_authService.isSignedIn) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken();
      if (idToken == null) {
        setState(() {
          _testResults = '❌ Failed to get ID token';
        });
        return;
      }
      final result = await _authService.testCreatePregnancyData(idToken);
      
      setState(() {
        _testResults = _formatTestResults(result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['success'] ? '✅ Data Created!' : '❌ Failed to Create Data'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

    } catch (error) {
      setState(() {
        _testResults = 'Error: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    setState(() {
      _userInfo = null;
      _testResults = '';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Signed out successfully'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _formatTestResults(Map<String, dynamic> result) {
    final buffer = StringBuffer();
    buffer.writeln('Test Result: ${result['success'] ? '✅ PASS' : '❌ FAIL'}');
    buffer.writeln('Message: ${result['message']}');
    buffer.writeln();
    
    if (result['user'] != null) {
      buffer.writeln('User Information:');
      result['user'].forEach((key, value) {
        buffer.writeln('  $key: $value');
      });
      buffer.writeln();
    }
    
    if (result['backend'] != null) {
      buffer.writeln('Backend Test Results:');
      buffer.writeln('  Success: ${result['backend']['success']}');
      buffer.writeln('  Message: ${result['backend']['message']}');
      
      if (result['backend']['sync'] != null) {
        buffer.writeln('  Sync Data: ${result['backend']['sync']}');
      }
      
      if (result['backend']['protectedEndpoint'] != null) {
        buffer.writeln('  Protected Endpoint: ${result['backend']['protectedEndpoint']}');
      }
    }
    
    return buffer.toString();
  }
}

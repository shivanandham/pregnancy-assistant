import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo and Title
              const Spacer(flex: 2),
              Icon(
                Icons.favorite,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Luma',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your Pregnancy Assistant',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              
              // Features
              _buildFeatureItem(
                context,
                Icons.track_changes,
                'Track Your Journey',
                'Monitor your pregnancy week by week',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                context,
                Icons.psychology,
                'AI Assistant',
                'Get personalized pregnancy guidance',
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                context,
                Icons.health_and_safety,
                'Health Monitoring',
                'Track symptoms, weight, and appointments',
              ),
              
              const Spacer(flex: 2),
              
              // Sign In Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return ElevatedButton.icon(
                    onPressed: authProvider.isLoading ? null : () async {
                      final success = await authProvider.signInWithGoogle();
                      if (success && context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else if (authProvider.error != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(authProvider.error!),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: authProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.login),
                    label: Text(
                      authProvider.isLoading 
                        ? (authProvider.isSignedIn ? 'Syncing...' : 'Signing in...')
                        : 'Sign in with Google',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Development Test Button (only show in debug mode)
              if (const bool.fromEnvironment('dart.vm.product') == false) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/test-auth');
                  },
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Test Authentication (Dev)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Privacy Notice
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy. Your data is securely stored and never shared.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

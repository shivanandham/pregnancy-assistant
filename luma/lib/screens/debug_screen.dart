import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Information'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environment Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            _buildInfoCard('Debug Mode', kDebugMode ? 'Enabled' : 'Disabled'),
            _buildInfoCard('Release Mode', kReleaseMode ? 'Enabled' : 'Disabled'),
            _buildInfoCard('Profile Mode', kProfileMode ? 'Enabled' : 'Disabled'),
            _buildInfoCard('Environment', ApiConfig.environment),
            _buildInfoCard('Base URL', ApiConfig.baseUrl),
            _buildInfoCard('Is Development', ApiConfig.isDevelopment ? 'Yes' : 'No'),
            _buildInfoCard('Is Production', ApiConfig.isProduction ? 'Yes' : 'No'),
            
            const SizedBox(height: 20),
            
            const Text(
              'How to Control Debug Mode:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            const Text('• Debug Mode: flutter run (default)'),
            const Text('• Release Mode: flutter run --release'),
            const Text('• Profile Mode: flutter run --profile'),
            const Text('• Build Release: flutter build apk --release'),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () {
                // Test API connection
                _testApiConnection(context);
              },
              child: const Text('Test API Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              value,
              style: TextStyle(
                color: title == 'Debug Mode' && value == 'Enabled' 
                    ? Colors.green 
                    : title == 'Base URL' && value.contains('localhost')
                        ? Colors.blue
                        : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testApiConnection(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Testing API Connection...'),
          content: const CircularProgressIndicator(),
        ),
      );
      
      // Test health endpoint
      final healthResult = await ApiService.checkHealth();
      
      // Test pregnancy data
      final pregnancyData = await ApiService.getPregnancyData();
      
      Navigator.pop(context); // Close loading dialog
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Test Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Health Check: ${healthResult ? "✅ Success" : "❌ Failed"}'),
              const SizedBox(height: 8),
              Text('Pregnancy Data: ${pregnancyData != null ? "✅ Success" : "❌ Failed"}'),
              const SizedBox(height: 8),
              Text('URL: ${ApiConfig.baseUrl}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Test Failed: $e')),
      );
    }
  }
}

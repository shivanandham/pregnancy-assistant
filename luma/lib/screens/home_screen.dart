import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/tracker_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/upcoming_appointments_card.dart';
import '../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<PregnancyProvider>().loadPregnancyData(),
      context.read<TrackerProvider>().loadAllData(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PregnancyProvider, TrackerProvider>(
      builder: (context, pregnancyProvider, trackerProvider, child) {
        if (pregnancyProvider.isLoading || trackerProvider.isLoadingSymptoms) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!pregnancyProvider.hasPregnancyData) {
          return _buildPregnancySetupForm(pregnancyProvider);
        }

        return Scaffold(
          body: Column(
            children: [
              // Debug banner for development
              if (kDebugMode)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.orange,
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'DEV: ${ApiConfig.baseUrl}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
                      stops: [0.0, 0.3],
                    ),
                  ),
                  child: SafeArea(
                    child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                DateFormat('EEEE, MMM dd').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Progress Card
                      ProgressCard(pregnancy: pregnancyProvider.pregnancy!),
                      
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.add_circle_outline,
                              title: 'Log Symptom',
                              color: AppTheme.firstTrimester,
                              onTap: () {
                                // Navigate to symptom logging
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.monitor_weight_outlined,
                              title: 'Add Weight',
                              color: AppTheme.secondTrimester,
                              onTap: () {
                                // Navigate to weight logging
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.event_outlined,
                              title: 'Add Appointment',
                              color: AppTheme.thirdTrimester,
                              onTap: () {
                                // Navigate to appointment adding
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: QuickActionCard(
                              icon: Icons.chat_bubble_outline,
                              title: 'Ask Assistant',
                              color: AppTheme.accentColor,
                              onTap: () {
                                // Navigate to chatbot
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Upcoming Appointments
                      if (trackerProvider.upcomingAppointments.isNotEmpty) ...[
                        const Text(
                          'Upcoming Appointments',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        UpcomingAppointmentsCard(appointments: trackerProvider.upcomingAppointments),
                      ],
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPregnancySetupForm(PregnancyProvider pregnancyProvider) {
    final _formKey = GlobalKey<FormState>();
    final _lastMenstrualPeriodController = TextEditingController();
    final _dueDateController = TextEditingController();
    final _notesController = TextEditingController();
    DateTime? _selectedLMP;
    DateTime? _selectedDueDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Luma'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.primaryColor, AppTheme.backgroundColor],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                const Text(
                  'Let\'s set up your pregnancy journey!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We need a few details to personalize your experience.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Form card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pregnancy Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Last Menstrual Period
                          TextFormField(
                            controller: _lastMenstrualPeriodController,
                            decoration: InputDecoration(
                              labelText: 'Last Menstrual Period',
                              hintText: 'Select date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 14)),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                _selectedLMP = date;
                                _lastMenstrualPeriodController.text = 
                                    DateFormat('MMM dd, yyyy').format(date);
                                
                                // Auto-calculate due date (LMP + 280 days)
                                _selectedDueDate = date.add(const Duration(days: 280));
                                _dueDateController.text = 
                                    DateFormat('MMM dd, yyyy').format(_selectedDueDate!);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your last menstrual period';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Due Date
                          TextFormField(
                            controller: _dueDateController,
                            decoration: InputDecoration(
                              labelText: 'Expected Due Date',
                              hintText: 'Auto-calculated or select manually',
                              prefixIcon: const Icon(Icons.event),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDueDate ?? DateTime.now().add(const Duration(days: 266)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                _selectedDueDate = date;
                                _dueDateController.text = 
                                    DateFormat('MMM dd, yyyy').format(date);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your due date';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Notes
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              labelText: 'Notes (Optional)',
                              hintText: 'Any additional information...',
                              prefixIcon: const Icon(Icons.note),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 32),
                          
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _savePregnancyData(
                                    pregnancyProvider,
                                    _selectedLMP!,
                                    _selectedDueDate!,
                                    _notesController.text.trim(),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Start My Journey',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _savePregnancyData(
    PregnancyProvider pregnancyProvider,
    DateTime lastMenstrualPeriod,
    DateTime dueDate,
    String notes,
  ) async {
    try {
      await pregnancyProvider.savePregnancyData(
        lastMenstrualPeriod: lastMenstrualPeriod,
        dueDate: dueDate,
        notes: notes.isEmpty ? null : notes,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregnancy data saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving pregnancy data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

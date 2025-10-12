import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/tracker_provider.dart';
import '../models/symptom.dart';
import '../models/weight_entry.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as CustomDateUtils;

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<TrackerProvider>(
            builder: (context, trackerProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshAllData(trackerProvider),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Symptoms', icon: Icon(Icons.health_and_safety_outlined)),
            Tab(text: 'Weight', icon: Icon(Icons.monitor_weight_outlined)),
            Tab(text: 'Appointments', icon: Icon(Icons.event_outlined)),
          ],
        ),
      ),
      body: Consumer<TrackerProvider>(
        builder: (context, trackerProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildSymptomsTab(trackerProvider),
              _buildWeightTab(trackerProvider),
              _buildAppointmentsTab(trackerProvider),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<TrackerProvider>(
        builder: (context, trackerProvider, child) {
          return FloatingActionButton(
            heroTag: "tracker_add_button",
            onPressed: () => _showAddDialog(trackerProvider),
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  Widget _buildSymptomsTab(TrackerProvider trackerProvider) {
    if (trackerProvider.isLoadingSymptoms) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => trackerProvider.refreshSymptoms(),
      child: trackerProvider.symptoms.isEmpty
          ? _buildEmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No Symptoms Logged',
              subtitle: 'Tap the + button to log your first symptom',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trackerProvider.symptoms.length,
              itemBuilder: (context, index) {
                final symptom = trackerProvider.symptoms[index];
                return _buildSymptomCard(symptom, trackerProvider);
              },
            ),
    );
  }

  Widget _buildWeightTab(TrackerProvider trackerProvider) {
    if (trackerProvider.isLoadingWeight) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => trackerProvider.refreshWeightEntries(),
      child: Column(
        children: [
          // Weight summary card
          if (trackerProvider.latestWeightEntry != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondTrimester.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.secondTrimester.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${trackerProvider.latestWeightEntry!.weight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Current Weight',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (trackerProvider.weightGain != null)
                    Column(
                      children: [
                        Text(
                          '${trackerProvider.weightGain!.toStringAsFixed(1)} kg',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: trackerProvider.weightGain! >= 0 
                                ? AppTheme.accentColor 
                                : AppTheme.errorColor,
                          ),
                        ),
                        const Text(
                          'Total Gain',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          
          // Weight entries list
          Expanded(
            child: trackerProvider.weightEntries.isEmpty
                ? _buildEmptyState(
                    icon: Icons.monitor_weight_outlined,
                    title: 'No Weight Entries',
                    subtitle: 'Tap the + button to log your first weight',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: trackerProvider.weightEntries.length,
                    itemBuilder: (context, index) {
                      final entry = trackerProvider.weightEntries[index];
                      return _buildWeightCard(entry, trackerProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(TrackerProvider trackerProvider) {
    if (trackerProvider.isLoadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => trackerProvider.refreshAppointments(),
      child: trackerProvider.appointments.isEmpty
          ? _buildEmptyState(
              icon: Icons.event_outlined,
              title: 'No Appointments',
              subtitle: 'Tap the + button to add your first appointment',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trackerProvider.appointments.length,
              itemBuilder: (context, index) {
                final appointment = trackerProvider.appointments[index];
                return _buildAppointmentCard(appointment, trackerProvider);
              },
            ),
    );
  }

  // Helper methods
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomCard(Symptom symptom, TrackerProvider trackerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSeverityColor(symptom.severity).withValues(alpha: 0.2),
          child: Icon(
            _getSymptomIcon(symptom.type),
            color: _getSeverityColor(symptom.severity),
          ),
        ),
        title: Text(
          symptom.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Severity: ${symptom.severity.name.toUpperCase()}'),
            if (symptom.notes != null && symptom.notes!.isNotEmpty)
              Text(symptom.notes!),
            Text(
              CustomDateUtils.DateUtils.formatDateTime(symptom.dateTime),
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
          onPressed: () => _showDeleteDialog(
            'Delete Symptom',
            'Are you sure you want to delete this symptom?',
            () => trackerProvider.deleteSymptom(symptom.id),
          ),
        ),
      ),
    );
  }

  Widget _buildWeightCard(WeightEntry entry, TrackerProvider trackerProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.secondTrimester.withValues(alpha: 0.2),
          child: const Icon(
            Icons.monitor_weight_outlined,
            color: AppTheme.secondTrimester,
          ),
        ),
        title: Text(
          '${entry.weight.toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.notes != null && entry.notes!.isNotEmpty)
              Text(entry.notes!),
            Text(
              CustomDateUtils.DateUtils.formatDate(entry.dateTime),
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
          onPressed: () => _showDeleteDialog(
            'Delete Weight Entry',
            'Are you sure you want to delete this weight entry?',
            () => trackerProvider.deleteWeightEntry(entry.id),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, TrackerProvider trackerProvider) {
    final isUpcoming = appointment.isUpcoming;
    final isToday = CustomDateUtils.DateUtils.isToday(appointment.dateTime);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getAppointmentColor(appointment).withValues(alpha: 0.2),
          child: Icon(
            _getAppointmentIcon(appointment.type),
            color: _getAppointmentColor(appointment),
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${appointment.type.name.toUpperCase()}'),
            if (appointment.location != null)
              Text('📍 ${appointment.location}'),
            if (appointment.doctor != null)
              Text('👨‍⚕️ ${appointment.doctor}'),
            Text(
              CustomDateUtils.DateUtils.formatDateTime(appointment.dateTime),
              style: TextStyle(
                fontSize: 12,
                color: isToday ? AppTheme.accentColor : AppTheme.textSecondary,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUpcoming)
              Checkbox(
                value: appointment.isCompleted,
                onChanged: (value) {
                  // Update appointment completion status
                  final updatedAppointment = appointment.copyWith(
                    isCompleted: value ?? false,
                    updatedAt: DateTime.now(),
                  );
                  trackerProvider.updateAppointment(appointment.id, updatedAppointment);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              onPressed: () => _showDeleteDialog(
                'Delete Appointment',
                'Are you sure you want to delete this appointment?',
                () => trackerProvider.deleteAppointment(appointment.id),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.mild:
        return AppTheme.accentColor;
      case SeverityLevel.moderate:
        return Colors.orange;
      case SeverityLevel.severe:
        return AppTheme.errorColor;
    }
  }

  IconData _getSymptomIcon(SymptomType type) {
    switch (type) {
      case SymptomType.nausea:
        return Icons.sick_outlined;
      case SymptomType.fatigue:
        return Icons.bedtime_outlined;
      case SymptomType.backPain:
        return Icons.healing_outlined;
      case SymptomType.heartburn:
        return Icons.local_fire_department_outlined;
      case SymptomType.moodSwings:
        return Icons.mood_outlined;
      case SymptomType.foodCravings:
        return Icons.restaurant_outlined;
      case SymptomType.headaches:
        return Icons.psychology_outlined;
      case SymptomType.swollenFeet:
        return Icons.directions_walk_outlined;
      case SymptomType.insomnia:
        return Icons.bedtime_outlined;
      case SymptomType.frequentUrination:
        return Icons.water_drop_outlined;
      case SymptomType.other:
        return Icons.health_and_safety_outlined;
    }
  }

  Color _getAppointmentColor(Appointment appointment) {
    if (appointment.isCompleted) return AppTheme.textSecondary;
    if (CustomDateUtils.DateUtils.isToday(appointment.dateTime)) return AppTheme.accentColor;
    if (appointment.isUpcoming) return AppTheme.primaryColor;
    return AppTheme.textSecondary;
  }

  IconData _getAppointmentIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.prenatal:
        return Icons.pregnant_woman_outlined;
      case AppointmentType.ultrasound:
        return Icons.visibility_outlined;
      case AppointmentType.bloodTest:
        return Icons.bloodtype_outlined;
      case AppointmentType.glucoseTest:
        return Icons.science_outlined;
      case AppointmentType.consultation:
        return Icons.person_outlined;
      case AppointmentType.other:
        return Icons.event_outlined;
    }
  }

  void _refreshAllData(TrackerProvider trackerProvider) async {
    await trackerProvider.loadAllData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _showAddDialog(TrackerProvider trackerProvider) {
    final currentTab = _tabController.index;
    
    switch (currentTab) {
      case 0: // Symptoms
        _showAddSymptomDialog(trackerProvider);
        break;
      case 1: // Weight
        _showAddWeightDialog(trackerProvider);
        break;
      case 2: // Appointments
        _showAddAppointmentDialog(trackerProvider);
        break;
    }
  }

  void _showAddSymptomDialog(TrackerProvider trackerProvider) {
    SymptomType selectedType = SymptomType.nausea;
    SeverityLevel selectedSeverity = SeverityLevel.mild;
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Symptom'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<SymptomType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Symptom Type'),
                  items: SymptomType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SeverityLevel>(
                  initialValue: selectedSeverity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: SeverityLevel.values.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Text(severity.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedSeverity = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date & Time'),
                  subtitle: Text(CustomDateUtils.DateUtils.formatDateTime(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final symptom = Symptom(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  type: selectedType,
                  severity: selectedSeverity,
                  dateTime: selectedDate,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  createdAt: DateTime.now(),
                );
                trackerProvider.addSymptom(symptom);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWeightDialog(TrackerProvider trackerProvider) {
    final weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Weight Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(CustomDateUtils.DateUtils.formatDate(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                if (weight != null && weight > 0) {
                  final weightEntry = WeightEntry(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    weight: weight,
                    dateTime: selectedDate,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  trackerProvider.addWeightEntry(weightEntry);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid weight')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAppointmentDialog(TrackerProvider trackerProvider) {
    final titleController = TextEditingController();
    AppointmentType selectedType = AppointmentType.prenatal;
    DateTime selectedDate = DateTime.now();
    final locationController = TextEditingController();
    final doctorController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AppointmentType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: AppointmentType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date & Time'),
                  subtitle: Text(CustomDateUtils.DateUtils.formatDateTime(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: doctorController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final appointment = Appointment(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    type: selectedType,
                    dateTime: selectedDate,
                    location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                    doctor: doctorController.text.trim().isEmpty ? null : doctorController.text.trim(),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    isCompleted: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  trackerProvider.addAppointment(appointment);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

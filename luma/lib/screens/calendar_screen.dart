import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/tracker_provider.dart';
import '../models/appointment.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart' as CustomDateUtils;
import '../services/device_timezone_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Appointment>> _selectedAppointments;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DeviceTimezoneService.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DeviceTimezoneService.now();
    _selectedAppointments = ValueNotifier(_getAppointmentsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedAppointments.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    final trackerProvider = context.read<TrackerProvider>();
    return trackerProvider.appointments.where((appointment) {
      return isSameDay(appointment.dateTime, day);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedAppointments.value = _getAppointmentsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<TrackerProvider>(
            builder: (context, trackerProvider, child) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => trackerProvider.refreshAppointments(),
              );
            },
          ),
        ],
      ),
      body: Consumer<TrackerProvider>(
        builder: (context, trackerProvider, child) {
          if (trackerProvider.isLoadingAppointments) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Calendar Widget
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TableCalendar<Appointment>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getAppointmentsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: const TextStyle(color: AppTheme.textPrimary),
                    holidayTextStyle: const TextStyle(color: AppTheme.textPrimary),
                    defaultTextStyle: const TextStyle(color: AppTheme.textPrimary),
                    selectedDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppTheme.secondTrimester,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerSize: 6,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: AppTheme.primaryColor,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  onDaySelected: _onDaySelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                ),
              ),

              // Selected Day Info
              if (_selectedDay != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Selected: ${CustomDateUtils.DateUtils.formatDate(_selectedDay!)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (CustomDateUtils.DateUtils.isToday(_selectedDay!))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Appointments for Selected Day
              Expanded(
                child: ValueListenableBuilder<List<Appointment>>(
                  valueListenable: _selectedAppointments,
                  builder: (context, appointments, _) {
                    if (appointments.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: appointments.length,
                      itemBuilder: (context, index) {
                        final appointment = appointments[index];
                        return _buildAppointmentCard(appointment, trackerProvider);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "calendar_add_button",
        onPressed: () => _showAddAppointmentDialog(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 64,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add an appointment',
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
                  final updatedAppointment = appointment.copyWith(
                    isCompleted: value ?? false,
                    updatedAt: DeviceTimezoneService.now(),
                  );
                  trackerProvider.updateAppointment(appointment.id, updatedAppointment);
                },
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              onPressed: () => _showDeleteDialog(appointment, trackerProvider),
            ),
          ],
        ),
      ),
    );
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

  void _showDeleteDialog(Appointment appointment, TrackerProvider trackerProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: Text('Are you sure you want to delete "${appointment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              trackerProvider.deleteAppointment(appointment.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final titleController = TextEditingController();
    AppointmentType selectedType = AppointmentType.prenatal;
    DateTime selectedDate = _selectedDay ?? DeviceTimezoneService.now();
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
                  value: selectedType,
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
                      firstDate: DeviceTimezoneService.now(),
                      lastDate: DeviceTimezoneService.now().add(const Duration(days: 365)),
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
                  final trackerProvider = context.read<TrackerProvider>();
                  final appointment = Appointment(
                    id: DeviceTimezoneService.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    type: selectedType,
                    dateTime: selectedDate,
                    location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                    doctor: doctorController.text.trim().isEmpty ? null : doctorController.text.trim(),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    isCompleted: false,
                    createdAt: DeviceTimezoneService.now(),
                    updatedAt: DeviceTimezoneService.now(),
                  );
                  trackerProvider.addAppointment(appointment);
                  Navigator.of(context).pop();
                  
                  // Update selected day to show the new appointment
                  _onDaySelected(selectedDate, selectedDate);
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

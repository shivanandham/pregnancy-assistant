import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _prePregnancyWeightController = TextEditingController();
  final _ageController = TextEditingController();
  final _localityController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _dietController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _smokingController = TextEditingController();
  final _alcoholController = TextEditingController();

  String _gender = 'female';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<UserProfileProvider>().loadUserProfile();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _prePregnancyWeightController.dispose();
    _ageController.dispose();
    _localityController.dispose();
    _timezoneController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _dietController.dispose();
    _exerciseController.dispose();
    _smokingController.dispose();
    _alcoholController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<UserProfileProvider>(
            builder: (context, provider, child) {
              if (provider.hasProfile) {
                return IconButton(
                  icon: Icon(_isEditing ? Icons.save : Icons.edit),
                  onPressed: () => _isEditing ? _saveProfile(provider) : _toggleEdit(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<UserProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadUserProfile(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasProfile) {
            return _buildCreateProfileForm(provider);
          }

          return _buildProfileDisplay(provider);
        },
      ),
    );
  }

  Widget _buildCreateProfileForm(UserProfileProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Your Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us personalize your pregnancy experience',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Basic Information
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Height is required';
                      }
                      final height = double.tryParse(value);
                      if (height == null || height < 100 || height > 250) {
                        return 'Enter a valid height (100-250 cm)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Current Weight (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Weight is required';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight < 30 || weight > 200) {
                        return 'Enter a valid weight (30-200 kg)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prePregnancyWeightController,
                    decoration: const InputDecoration(
                      labelText: 'Pre-pregnancy Weight (kg)',
                      border: OutlineInputBorder(),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final weight = double.tryParse(value);
                        if (weight == null || weight < 30 || weight > 200) {
                          return 'Enter a valid weight (30-200 kg)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      suffixText: 'years',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Age is required';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 16 || age > 50) {
                        return 'Enter a valid age (16-50)';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() {
                  _gender = value ?? 'female';
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _localityController,
              decoration: const InputDecoration(
                labelText: 'Location (City, Country)',
                border: OutlineInputBorder(),
                hintText: 'e.g., Mumbai, India',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _timezoneController,
              decoration: const InputDecoration(
                labelText: 'Timezone',
                border: OutlineInputBorder(),
                hintText: 'e.g., Asia/Kolkata',
              ),
            ),
            const SizedBox(height: 24),
            
            // Medical Information
            _buildSectionHeader('Medical Information'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _medicalHistoryController,
              decoration: const InputDecoration(
                labelText: 'Medical History (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., migraine, anemia',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _allergiesController,
              decoration: const InputDecoration(
                labelText: 'Allergies (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., penicillin, shellfish',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _medicationsController,
              decoration: const InputDecoration(
                labelText: 'Current Medications (comma-separated)',
                border: OutlineInputBorder(),
                hintText: 'e.g., prenatal vitamins, iron supplements',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Lifestyle Information
            _buildSectionHeader('Lifestyle'),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _dietController,
              decoration: const InputDecoration(
                labelText: 'Diet',
                border: OutlineInputBorder(),
                hintText: 'e.g., vegetarian, vegan, omnivore',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _exerciseController,
              decoration: const InputDecoration(
                labelText: 'Exercise Routine',
                border: OutlineInputBorder(),
                hintText: 'e.g., yoga 3x/week, walking daily',
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _smokingController,
                    decoration: const InputDecoration(
                      labelText: 'Smoking',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., never, former, current',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _alcoholController,
                    decoration: const InputDecoration(
                      labelText: 'Alcohol',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., never, occasional, regular',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _createProfile(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Create Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDisplay(UserProfileProvider provider) {
    final profile = provider.profile!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${profile.age} years old',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if (profile.locality != null)
                  Text(
                    profile.locality!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Health Stats
          _buildSectionHeader('Health Statistics'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Height',
                  '${profile.height?.toStringAsFixed(0) ?? 'N/A'} cm',
                  Icons.height,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Current Weight',
                  '${profile.weight?.toStringAsFixed(1) ?? 'N/A'} kg',
                  Icons.monitor_weight,
                  AppTheme.secondTrimester,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'BMI',
                  profile.bmi != null ? profile.bmi!.toStringAsFixed(1) : 'N/A',
                  Icons.analytics,
                  AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Weight Gain',
                  profile.weightGain != null ? '${profile.weightGain!.toStringAsFixed(1)} kg' : 'N/A',
                  Icons.trending_up,
                  profile.weightGain != null && profile.weightGain! >= 0 
                      ? AppTheme.accentColor 
                      : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Medical Information
          if (profile.medicalContext.isNotEmpty) ...[
            _buildSectionHeader('Medical Information'),
            const SizedBox(height: 16),
            _buildInfoCard(
              Icons.medical_services,
              'Medical Context',
              profile.medicalContext,
            ),
            const SizedBox(height: 24),
          ],
          
          // Profile Details
          _buildSectionHeader('Profile Details'),
          const SizedBox(height: 16),
          
          if (_isEditing) ...[
            _buildEditableProfileForm(provider),
          ] else ...[
            _buildProfileInfo(profile),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Column(
      children: [
        _buildInfoRow('Gender', profile.gender),
        if (profile.prePregnancyWeight != null)
          _buildInfoRow('Pre-pregnancy Weight', '${profile.prePregnancyWeight!.toStringAsFixed(1)} kg'),
        if (profile.timezone != null)
          _buildInfoRow('Timezone', profile.timezone!),
        if (profile.medicalHistory != null && profile.medicalHistory!.isNotEmpty)
          _buildInfoRow('Medical History', profile.medicalHistory!.join(', ')),
        if (profile.allergies != null && profile.allergies!.isNotEmpty)
          _buildInfoRow('Allergies', profile.allergies!.join(', ')),
        if (profile.medications != null && profile.medications!.isNotEmpty)
          _buildInfoRow('Medications', profile.medications!.join(', ')),
        if (profile.lifestyle != null) ...[
          if (profile.lifestyle!.diet != null)
            _buildInfoRow('Diet', profile.lifestyle!.diet!),
          if (profile.lifestyle!.exercise != null)
            _buildInfoRow('Exercise', profile.lifestyle!.exercise!),
          if (profile.lifestyle!.smoking != null)
            _buildInfoRow('Smoking', profile.lifestyle!.smoking!),
          if (profile.lifestyle!.alcohol != null)
            _buildInfoRow('Alcohol', profile.lifestyle!.alcohol!),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileForm(UserProfileProvider provider) {
    // Populate controllers with current values
    final profile = provider.profile!;
    _heightController.text = profile.height?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _prePregnancyWeightController.text = profile.prePregnancyWeight?.toString() ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _localityController.text = profile.locality ?? '';
    _timezoneController.text = profile.timezone ?? '';
    _medicalHistoryController.text = profile.medicalHistory?.join(', ') ?? '';
    _allergiesController.text = profile.allergies?.join(', ') ?? '';
    _medicationsController.text = profile.medications?.join(', ') ?? '';
    _dietController.text = profile.lifestyle?.diet ?? '';
    _exerciseController.text = profile.lifestyle?.exercise ?? '';
    _smokingController.text = profile.lifestyle?.smoking ?? '';
    _alcoholController.text = profile.lifestyle?.alcohol ?? '';
    _gender = profile.gender;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Basic fields (similar to create form but with current values)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                    suffixText: 'cm',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Current Weight (kg)',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _prePregnancyWeightController,
                  decoration: const InputDecoration(
                    labelText: 'Pre-pregnancy Weight (kg)',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                    suffixText: 'years',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _gender = value ?? 'female';
              });
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _localityController,
            decoration: const InputDecoration(
              labelText: 'Location (City, Country)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _timezoneController,
            decoration: const InputDecoration(
              labelText: 'Timezone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _medicalHistoryController,
            decoration: const InputDecoration(
              labelText: 'Medical History (comma-separated)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _allergiesController,
            decoration: const InputDecoration(
              labelText: 'Allergies (comma-separated)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _medicationsController,
            decoration: const InputDecoration(
              labelText: 'Current Medications (comma-separated)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _dietController,
            decoration: const InputDecoration(
              labelText: 'Diet',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _exerciseController,
            decoration: const InputDecoration(
              labelText: 'Exercise Routine',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _smokingController,
                  decoration: const InputDecoration(
                    labelText: 'Smoking',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _alcoholController,
                  decoration: const InputDecoration(
                    labelText: 'Alcohol',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _toggleEdit,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveProfile(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _createProfile(UserProfileProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final lifestyle = Lifestyle(
      diet: _dietController.text.trim().isEmpty ? null : _dietController.text.trim(),
      exercise: _exerciseController.text.trim().isEmpty ? null : _exerciseController.text.trim(),
      smoking: _smokingController.text.trim().isEmpty ? null : _smokingController.text.trim(),
      alcohol: _alcoholController.text.trim().isEmpty ? null : _alcoholController.text.trim(),
    );

    final success = await provider.createProfile(
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      prePregnancyWeight: _prePregnancyWeightController.text.trim().isEmpty 
          ? null 
          : double.parse(_prePregnancyWeightController.text),
      age: int.parse(_ageController.text),
      gender: _gender,
      locality: _localityController.text.trim().isEmpty ? null : _localityController.text.trim(),
      timezone: _timezoneController.text.trim().isEmpty ? null : _timezoneController.text.trim(),
      medicalHistory: _medicalHistoryController.text.trim().isEmpty 
          ? null 
          : _medicalHistoryController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      allergies: _allergiesController.text.trim().isEmpty 
          ? null 
          : _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      medications: _medicationsController.text.trim().isEmpty 
          ? null 
          : _medicationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      lifestyle: lifestyle,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile created successfully!'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }

  void _saveProfile(UserProfileProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final updates = <String, dynamic>{};
    
    if (_heightController.text.isNotEmpty) {
      updates['height'] = double.parse(_heightController.text);
    }
    if (_weightController.text.isNotEmpty) {
      updates['weight'] = double.parse(_weightController.text);
    }
    if (_prePregnancyWeightController.text.isNotEmpty) {
      updates['prePregnancyWeight'] = double.parse(_prePregnancyWeightController.text);
    }
    if (_ageController.text.isNotEmpty) {
      updates['age'] = int.parse(_ageController.text);
    }
    
    updates['gender'] = _gender;
    updates['locality'] = _localityController.text.trim().isEmpty ? null : _localityController.text.trim();
    updates['timezone'] = _timezoneController.text.trim().isEmpty ? null : _timezoneController.text.trim();
    
    updates['medicalHistory'] = _medicalHistoryController.text.trim().isEmpty 
        ? null 
        : _medicalHistoryController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    updates['allergies'] = _allergiesController.text.trim().isEmpty 
        ? null 
        : _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    updates['medications'] = _medicationsController.text.trim().isEmpty 
        ? null 
        : _medicationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    final lifestyle = Lifestyle(
      diet: _dietController.text.trim().isEmpty ? null : _dietController.text.trim(),
      exercise: _exerciseController.text.trim().isEmpty ? null : _exerciseController.text.trim(),
      smoking: _smokingController.text.trim().isEmpty ? null : _smokingController.text.trim(),
      alcohol: _alcoholController.text.trim().isEmpty ? null : _alcoholController.text.trim(),
    );
    updates['lifestyle'] = lifestyle.toJson();

    final success = await provider.updateUserProfile(updates);

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    }
  }
}

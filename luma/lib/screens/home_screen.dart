import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/home_provider.dart';
import '../models/pregnancy_tip.dart';
import '../models/pregnancy_milestone.dart';
import '../models/daily_checklist.dart';
import '../models/pregnancy.dart';
import '../services/device_timezone_service.dart';
import '../services/api_service.dart';
import '../widgets/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _tipPageController;
  late AnimationController _tipAnimationController;
  int _currentTipIndex = 0;
  Set<String> _completedChecklistItems = {};
  
  // Pregnancy setup form state
  final _formKey = GlobalKey<FormState>();
  final _lmpController = TextEditingController();
  final _dueDateController = TextEditingController();
  DateTime? _lastMenstrualPeriod;
  DateTime? _dueDate;
  int _cycleLength = 28; // Default 28-day cycle
  bool _isSubmitting = false;
  

  @override
  void initState() {
    super.initState();
    _tipPageController = PageController();
    _tipAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // Auto-advance tips every 5 seconds
    _startTipCarousel();
    _loadCompletedChecklistItems();
  }

  @override
  void dispose() {
    _tipPageController.dispose();
    _tipAnimationController.dispose();
    _lmpController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }


  void _startTipCarousel() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final homeProvider = context.read<HomeProvider>();
        final tips = homeProvider.tips;
        if (tips.isNotEmpty) {
          _currentTipIndex = (_currentTipIndex + 1) % tips.length;
          _tipPageController.animateToPage(
            _currentTipIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _startTipCarousel();
        }
      }
    });
  }

  Future<void> _loadCompletedChecklistItems() async {
    try {
      final today = DeviceTimezoneService.now();
      final completedItems = await ApiService.getChecklistCompletions(today);
      if (mounted) {
        setState(() {
          _completedChecklistItems = completedItems.toSet();
        });
      }
    } catch (e) {
      print('Error loading completed checklist items: $e');
    }
  }

  Future<void> _selectLMPDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _lastMenstrualPeriod ?? DeviceTimezoneService.now().subtract(const Duration(days: 14 * 7)),
      firstDate: DeviceTimezoneService.now().subtract(const Duration(days: 42 * 7)),
      lastDate: DeviceTimezoneService.now(),
    );
    if (date != null) {
      setState(() {
        _lastMenstrualPeriod = date;
        _lmpController.text = _formatDate(date);
        // Calculate due date using American Pregnancy Association method: LMP + 280 days (40 weeks)
        _dueDate = _calculateDueDateFromLMP(date);
        _dueDateController.text = _formatDate(_dueDate!);
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DeviceTimezoneService.now().add(const Duration(days: 26 * 7)),
      firstDate: DeviceTimezoneService.now(),
      lastDate: DeviceTimezoneService.now().add(const Duration(days: 42 * 7)),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
        _dueDateController.text = _formatDate(date);
        // Calculate LMP using American Pregnancy Association method: Due date - 280 days (40 weeks)
        _lastMenstrualPeriod = _calculateLMPFromDueDate(date);
        _lmpController.text = _formatDate(_lastMenstrualPeriod!);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${_getShortMonthName(date.month)} ${date.day}, ${date.year}';
  }

  /// Calculate due date from LMP using American Pregnancy Association method
  /// Adjusts for cycle length: LMP + (280 + (cycleLength - 28)) days
  DateTime _calculateDueDateFromLMP(DateTime lmp) {
    // Standard 280 days + adjustment for cycle length
    final adjustment = _cycleLength - 28;
    return lmp.add(Duration(days: 280 + adjustment));
  }

  /// Calculate LMP from due date using American Pregnancy Association method
  /// Adjusts for cycle length: Due date - (280 + (cycleLength - 28)) days
  DateTime _calculateLMPFromDueDate(DateTime dueDate) {
    // Standard 280 days + adjustment for cycle length
    final adjustment = _cycleLength - 28;
    return dueDate.subtract(Duration(days: 280 + adjustment));
  }

  int _calculateCurrentWeek() {
    if (_lastMenstrualPeriod == null) return 0;
    final daysSinceLMP = DeviceTimezoneService.now().difference(_lastMenstrualPeriod!).inDays;
    return (daysSinceLMP / 7).floor() + 1;
  }

  int _calculateDaysRemaining() {
    if (_dueDate == null) return 0;
    return _dueDate!.difference(DeviceTimezoneService.now()).inDays;
  }

  Widget _buildTimelineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPregnancyData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lastMenstrualPeriod == null || _dueDate == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pregnancy = Pregnancy(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dueDate: _dueDate!,
        lastMenstrualPeriod: _lastMenstrualPeriod!,
        createdAt: DeviceTimezoneService.now(),
        updatedAt: DeviceTimezoneService.now(),
      );

      await ApiService.savePregnancyData(pregnancy);
      
      if (mounted) {
        // Reload pregnancy data to update the UI
        await context.read<PregnancyProvider>().loadPregnancyData();
        await context.read<HomeProvider>().loadHomeData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<PregnancyProvider, HomeProvider>(
        builder: (context, pregnancyProvider, homeProvider, child) {
          // Show pregnancy setup form only after base home data has loaded
          if (homeProvider.homeData != null && !homeProvider.hasPregnancyData && !homeProvider.isLoading) {
            return _buildPregnancySetupForm(pregnancyProvider);
          }

          // Show error for basic home data loading only if we have an error and no pregnancy data
          if (homeProvider.homeData != null && homeProvider.error != null && !homeProvider.hasPregnancyData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading home data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    homeProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => homeProvider.refreshHomeData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await homeProvider.refreshHomeData();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildWelcomeHeader(pregnancyProvider.pregnancy),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: _buildQuickStats(pregnancyProvider.pregnancy),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: _buildSectionHeader('Today\'s Focus', Icons.today),
                  ),
                ),
                SliverToBoxAdapter(
                  child: homeProvider.isLoadingTips
                      ? const TipsSkeletonLoader()
                      : homeProvider.tipsError != null
                          ? Container(
                              height: 200,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[300]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load tips',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                    TextButton(
                                      onPressed: () => homeProvider.refreshTips(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 200,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: _buildTodayFocusCarousel(homeProvider.tips),
                            ),
                ),
                // Milestones section with individual loading state
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: _buildSectionHeader('This Week', Icons.calendar_view_week),
                  ),
                ),
                SliverToBoxAdapter(
                  child: homeProvider.isLoadingMilestones
                      ? const MilestonesSkeletonLoader()
                      : homeProvider.milestonesError != null
                          ? Container(
                              height: 120,
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[300]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load milestones',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                    TextButton(
                                      onPressed: () => homeProvider.refreshMilestones(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : homeProvider.currentMilestones.isNotEmpty
                              ? _buildWeekMilestones(homeProvider.currentMilestones)
                              : const SizedBox.shrink(),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: _buildChecklistSectionHeader(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: homeProvider.isLoadingChecklist
                      ? const ChecklistSkeletonLoader()
                      : homeProvider.checklistError != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[300]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Failed to load checklist',
                                      style: TextStyle(color: Colors.red[300]),
                                    ),
                                    TextButton(
                                      onPressed: () => homeProvider.refreshChecklist(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildChecklistGrid(homeProvider.checklistByCategory),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeHeader(pregnancy) {
    if (pregnancy == null) return const SizedBox.shrink();
    
    final currentWeek = pregnancy.currentWeek;
    final trimester = _getTrimesterText(currentWeek);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pregnant_woman,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $currentWeek',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      trimester,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(pregnancy.progressPercentage * 100).round()}% Complete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(pregnancy) {
    if (pregnancy == null) return const SizedBox.shrink();
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Due Date',
            _formatDueDate(pregnancy.dueDate),
            Icons.calendar_today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Days Left',
            '${pregnancy.daysUntilDueDate}',
            Icons.schedule,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChecklistSectionHeader() {
    return Row(
      children: [
        Icon(
          Icons.checklist,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Text(
          'Daily Checklist',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Auto-generated daily',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayFocusCarousel(List<PregnancyTip> tips) {
    if (tips.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Center(
          child: Text(
            'No tips available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _tipPageController,
      onPageChanged: (index) {
        setState(() {
          _currentTipIndex = index;
        });
      },
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    tip.categoryIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tip.categoryDisplayName,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  tip.tip,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekMilestones(List<PregnancyMilestone> milestones) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: milestones.length,
        itemBuilder: (context, index) {
          final milestone = milestones[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: milestone.important
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: milestone.important
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.grey[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      milestone.categoryIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        milestone.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: milestone.important
                              ? AppTheme.primaryColor
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChecklistGrid(Map<String, List<DailyChecklist>> checklistByCategory) {
    if (checklistByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: checklistByCategory.entries.map((entry) {
          final category = entry.key;
          final items = entry.value;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () async {
                      // Optimistically update UI
                      setState(() {
                        if (_completedChecklistItems.contains(item.id)) {
                          _completedChecklistItems.remove(item.id);
                        } else {
                          _completedChecklistItems.add(item.id);
                        }
                      });

                      // Make API call
                      final success = await ApiService.toggleChecklistCompletion(item.id);
                      
                      // If API call failed, revert the UI change
                      if (!success) {
                        setState(() {
                          if (_completedChecklistItems.contains(item.id)) {
                            _completedChecklistItems.remove(item.id);
                          } else {
                            _completedChecklistItems.add(item.id);
                          }
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          _completedChecklistItems.contains(item.id)
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          size: 20,
                          color: _completedChecklistItems.contains(item.id)
                              ? AppTheme.primaryColor
                              : Colors.grey[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.task,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: _completedChecklistItems.contains(item.id)
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: _completedChecklistItems.contains(item.id)
                                  ? Colors.grey[600]
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                if (items.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${items.length - 3} more',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPregnancyProgressCard(pregnancy) {
    if (pregnancy == null) return const SizedBox.shrink();

    final currentWeek = pregnancy.currentWeek;
    final daysUntilDue = pregnancy.daysUntilDueDate;
    final progressPercentage = pregnancy.progressPercentage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.primaryColor.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pregnant_woman,
                color: AppTheme.primaryColor,
                size: 36,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $currentWeek',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTrimesterText(currentWeek),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Due Date',
                  _formatDueDate(pregnancy.dueDate),
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildProgressItem(
                  'Days Left',
                  daysUntilDue > 0 ? '$daysUntilDue days' : 'Overdue!',
                  Icons.schedule,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(progressPercentage),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildTipOfTheDayCarousel(List<PregnancyTip> tips) {
    if (tips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Tip of the Day',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _tipPageController,
            onPageChanged: (index) {
              setState(() {
                _currentTipIndex = index;
              });
            },
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return _buildTipCard(tip);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            tips.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == _currentTipIndex
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(PregnancyTip tip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tip.categoryIcon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip.categoryDisplayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              tip.tip,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatToExpectSection(List<PregnancyMilestone> milestones) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'What to Expect This Week',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...milestones.map((milestone) => _buildMilestoneCard(milestone)),
      ],
    );
  }

  Widget _buildMilestoneCard(PregnancyMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: milestone.important
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: milestone.important
              ? AppTheme.primaryColor.withValues(alpha: 0.3)
              : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: milestone.important
                  ? AppTheme.primaryColor
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              milestone.categoryIcon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: milestone.important
                        ? AppTheme.primaryColor
                        : null,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChecklistSection(Map<String, List<DailyChecklist>> checklistByCategory) {
    if (checklistByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Daily Checklist',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...checklistByCategory.entries.map((entry) {
          return _buildChecklistCategory(entry.key, entry.value);
        }),
      ],
    );
  }

  Widget _buildChecklistCategory(String category, List<DailyChecklist> tasks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                tasks.first.categoryIcon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                tasks.first.categoryDisplayName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...tasks.map((task) => _buildChecklistItem(task)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(DailyChecklist task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: task.important
                ? Icon(
                    Icons.star,
                    size: 12,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task.task,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: task.important ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMilestonesSection(List<PregnancyMilestone> upcomingMilestones) {
    if (upcomingMilestones.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Milestones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcomingMilestones.map((milestone) => _buildUpcomingMilestoneCard(milestone)),
      ],
    );
  }

  Widget _buildUpcomingMilestoneCard(PregnancyMilestone milestone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Week ${milestone.week}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancySetupForm(PregnancyProvider pregnancyProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Luma'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.pregnant_woman,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Let\'s Start Your Journey',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tell us about your pregnancy to get personalized tips and guidance.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Last Menstrual Period',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the first day of your last menstrual period',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lmpController,
                        decoration: const InputDecoration(
                          hintText: 'Select date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: _selectLMPDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your last menstrual period';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Cycle Length Field
                      Text(
                        'Average Cycle Length',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Number of days in your menstrual cycle (22-44 days)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _cycleLength.toDouble(),
                              min: 22,
                              max: 44,
                              divisions: 22,
                              label: '$_cycleLength days',
                              onChanged: (value) {
                                setState(() {
                                  _cycleLength = value.round();
                                  // Recalculate due date if LMP is set
                                  if (_lastMenstrualPeriod != null) {
                                    _dueDate = _calculateDueDateFromLMP(_lastMenstrualPeriod!);
                                    _dueDateController.text = _formatDate(_dueDate!);
                                  }
                                });
                              },
                            ),
                          ),
                          Container(
                            width: 60,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_cycleLength',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Text(
                        'Expected Due Date',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Automatically calculated based on LMP and cycle length',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dueDateController,
                        decoration: const InputDecoration(
                          hintText: 'Select date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        onTap: _selectDueDate,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your expected due date';
                          }
                          return null;
                        },
                      ),
                      
                      // Show pregnancy timeline when dates are selected
                      if (_lastMenstrualPeriod != null && _dueDate != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timeline,
                                    color: AppTheme.primaryColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Pregnancy Timeline',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTimelineItem('Current Week', 'Week ${_calculateCurrentWeek()}'),
                              _buildTimelineItem('Trimester', _getTrimesterText(_calculateCurrentWeek())),
                              _buildTimelineItem('Days Remaining', '${_calculateDaysRemaining()} days'),
                              _buildTimelineItem('Cycle Length', '$_cycleLength days'),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      
                      // Disclaimer similar to American Pregnancy Association
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This is an estimate based on standard medical calculations adjusted for your cycle length. Only about 5% of babies are born on their exact due date.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20), // Extra bottom padding
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitPregnancyData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Start My Journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTrimesterText(int week) {
    if (week <= 12) return 'First Trimester';
    if (week <= 26) return 'Second Trimester';
    return 'Third Trimester';
  }

  String _formatDueDate(DateTime dueDate) {
    // Format as "Mon DD, YYYY" (e.g., "Jan 15, 2025")
    return '${_getShortMonthName(dueDate.month)} ${dueDate.day}, ${dueDate.year}';
  }

  String _getShortMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
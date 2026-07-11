import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/habit_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/radius.dart';
import '../../../core/theme/spacing.dart';
import '../../shared/widgets/app_card.dart';
import '../../../shared/widgets/soft_ui.dart';

class MonthlyHabitTrackerPage extends StatelessWidget {
  const MonthlyHabitTrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM').format(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('$monthLabel Habit Tracker'),
      ),
      body: const MonthlyHabitTrackerWidget(),
    );
  }
}

class MonthlyHabitTrackerWidget extends ConsumerStatefulWidget {
  const MonthlyHabitTrackerWidget({super.key});

  @override
  ConsumerState<MonthlyHabitTrackerWidget> createState() => _MonthlyHabitTrackerWidgetState();
}

enum FilterMode { month, week }

class _MonthlyHabitTrackerWidgetState extends ConsumerState<MonthlyHabitTrackerWidget> {
  static const double _leftColumnWidth = 170;
  static const double _dayCellWidth = 40;
  static const double _rowHeight = 42;
  static const double _summaryColumnWidth = 110;

  late DateTime _month;
  late List<DateTime> _days;
  late final ScrollController _gridHorizontalController;
  late List<DailyMetrics> _dailyMetrics;
  FilterMode _filterMode = FilterMode.month;
  int _selectedWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
    _days = _buildDaysForMonth(_month);
    _gridHorizontalController = ScrollController();
    _dailyMetrics = _days
        .map((date) => DailyMetrics(date: _dateKey(date), hoursOfSleep: 6 + (date.day % 4)))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitBoardProvider.notifier).ensureLoaded();
    });
  }

  @override
  void dispose() {
    _gridHorizontalController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  bool _habitActiveOn(TrackedHabit habit, DateTime date) => habit.isActiveOn(date);

  List<DateTime> _buildDaysForMonth(DateTime month) {
    final count = DateUtils.getDaysInMonth(month.year, month.month);
    return List.generate(count, (index) => DateTime(month.year, month.month, index + 1));
  }

  int get totalPossibleCheckBoxes => ref.watch(habitBoardProvider).fold(0, (sum, habit) {
        return sum + _visibleDays.where((day) => _habitActiveOn(habit, day)).length;
      });

  int get totalCompletedCheckBoxes => ref.watch(habitBoardProvider).fold(0, (sum, habit) {
        return sum + _visibleDays.where((day) => _habitActiveOn(habit, day) && habit.completions[_dateKey(day)] == true).length;
      });

  double get monthlyProgress => totalPossibleCheckBoxes == 0 ? 0 : totalCompletedCheckBoxes / totalPossibleCheckBoxes;

  int get completedHabitsCount => totalCompletedCheckBoxes;

  List<int> get dailyCompletedCounts => _visibleDays
      .map((date) => ref.watch(habitBoardProvider).where((habit) => _habitActiveOn(habit, date) && habit.completions[_dateKey(date)] == true).length)
      .toList();

  int get maxDailyCompleted => dailyCompletedCounts.isEmpty ? 1 : dailyCompletedCounts.reduce((a, b) => a > b ? a : b).clamp(1, 100);

  List<FlSpot> get progressSpots => dailyCompletedCounts.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble())).toList();

  List<FlSpot> get sleepSpots => _visibleDays
      .asMap()
      .entries
      .map((entry) {
        final dateKey = _dateKey(entry.value);
        final metric = _dailyMetrics.firstWhere((m) => m.date == dateKey, orElse: () => DailyMetrics(date: dateKey, hoursOfSleep: 0));
        return FlSpot(entry.key.toDouble(), metric.hoursOfSleep.toDouble());
      })
      .toList();

  double _habitProgressRatio(TrackedHabit habit) {
    final activeDays = _visibleDays.where((d) => _habitActiveOn(habit, d)).toList();
    if (activeDays.isEmpty) return 0;
    final completed = activeDays.where((d) => habit.completions[_dateKey(d)] == true).length;
    return completed / activeDays.length;
  }

  void _updateSleep(String dateKey, String rawValue) {
    final parsed = int.tryParse(rawValue) ?? 0;
    final index = _dailyMetrics.indexWhere((metric) => metric.date == dateKey);
    if (index == -1) return;
    setState(() {
      _dailyMetrics[index] = DailyMetrics(date: dateKey, hoursOfSleep: parsed);
    });
  }

  List<DateTime> get _visibleDays {
    if (_filterMode == FilterMode.month) return _days;
    // week mode: return days for the selected week group
    final groups = _weekGroups;
    if (_selectedWeekIndex < 0 || _selectedWeekIndex >= groups.length) return _days;
    final startIndex = groups.take(_selectedWeekIndex).fold<int>(0, (p, g) => p + g.count);
    final count = groups[_selectedWeekIndex].count;
    return _days.skip(startIndex).take(count).toList();
  }

  String _dayLabel(DateTime date) {
    return DateFormat('EE').format(date).substring(0, 2);
  }

  List<WeekGroup> get _weekGroups {
    final List<WeekGroup> groups = [];
    int index = 0;
    while (index < _days.length) {
      final remaining = _days.length - index;
      final size = remaining >= 7 ? 7 : remaining;
      groups.add(WeekGroup(label: 'Week ${groups.length + 1}', count: size));
      index += size;
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthLabel = DateFormat('MMMM').format(_month);
    return Scaffold(
      appBar: AppBar(
        title: Text('$monthLabel Habit Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, monthLabel),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: _buildMatrixSection(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, String monthLabel) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: large month block (matches mockup)
            Container(
              width: 160,
              height: 96,
              margin: const EdgeInsets.only(right: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              alignment: Alignment.center,
              child: Text(monthLabel.toUpperCase(), style: theme.textTheme.headlineLarge?.copyWith(fontSize: 40, fontWeight: FontWeight.w900)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Center area: Weekly & Monthly progress bars
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Weekly Progress', style: theme.textTheme.titleSmall),
                            const SizedBox(height: AppSpacing.xs),
                            _buildLargeProgressBar(monthlyProgress * 0.4),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Monthly Progress', style: theme.textTheme.titleSmall),
                            const SizedBox(height: AppSpacing.xs),
                            _buildLargeProgressBar(monthlyProgress),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Action buttons (add / delete / edit) styled as gray blocks like the mock
                  Row(
                    children: [
                      _actionBlockButton('add habit', Icons.add, onPressed: _showAddHabitDialog),
                      const SizedBox(width: AppSpacing.sm),
                      _actionBlockButton('delete habit', Icons.remove, onPressed: () {/* no-op: select then delete in manage sheet */}),
                      const SizedBox(width: AppSpacing.sm),
                      _actionBlockButton('edit habits', Icons.edit, onPressed: _openManageHabitsSheet),
                    ],
                  ),
                ],
              ),
            ),
            // Right: view selector + edit layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ToggleButtons(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  fillColor: AppColors.primaryMedium,
                  selectedBorderColor: AppColors.primaryButtonBlue,
                  selectedColor: AppColors.white,
                  color: AppColors.textSecondary,
                  borderColor: AppColors.border,
                  selectedBorderWidth: 1.5,
                  isSelected: [_filterMode == FilterMode.month, _filterMode == FilterMode.week],
                  onPressed: (i) {
                    setState(() {
                      _filterMode = i == 0 ? FilterMode.month : FilterMode.week;
                      _selectedWeekIndex = 0;
                    });
                  },
                  children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), child: Text('Month')), Padding(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8), child: Text('Week'))],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 64,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(child: Text('edit\nlayout', textAlign: TextAlign.center, style: theme.textTheme.bodySmall)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBlockButton(String label, IconData icon, {required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 16, color: AppColors.textPrimary), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildLargeProgressBar(double fraction) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 28,
        color: AppColors.surface,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: AppColors.surface)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(color: AppColors.primaryButtonBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _squareCheck({required bool checked, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: checked ? AppColors.primaryButtonBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: checked
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildMetricBadge(ThemeData theme, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: theme.textTheme.bodySmall),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildMatrixSection(ThemeData theme) {
    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGridHeader(theme),
              const SizedBox(height: AppSpacing.sm),
              _buildScrollableGrid(theme),
              const SizedBox(height: AppSpacing.sm),
              _buildSleepRow(theme),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildHabitCountHistogram(theme),
        const SizedBox(height: AppSpacing.lg),
        _buildChartsSection(theme),
      ],
    );
  }

  void _openManageHabitsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheetState) {
          final habits = ref.watch(habitBoardProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12))),
              const SizedBox(height: 12),
              const Text('Edit habit layout', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 360,
                child: ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    ref.read(habitBoardProvider.notifier).reorderHabits(oldIndex, newIndex);
                    setSheetState(() {});
                  },
                  children: [
                    for (var i = 0; i < habits.length; i++)
                      ListTile(
                        key: ValueKey(habits[i].id),
                        title: Text('${habits[i].name} ${habits[i].emoji}'),
                        subtitle: Text(habits[i].scheduleLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        leading: const Icon(Icons.drag_handle),
                      ),
                  ],
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  Widget _buildGridHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _leftColumnWidth,
          height: _rowHeight * 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Habits', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _gridHorizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _visibleDays.length * _dayCellWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: _buildWeekHeaders(theme)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: _buildDayOfWeekHeaders(theme)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: _buildDayNumberHeaders(theme)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: _summaryColumnWidth,
          child: Center(child: Text('Habit %', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
        ),
      ],
    );
  }

  List<Widget> _buildWeekHeaders(ThemeData theme) {
    final groups = _weekGroups;
    final toUse = _filterMode == FilterMode.week ? [groups[_selectedWeekIndex]] : groups;
    return toUse
        .map(
          (group) => Container(
            width: group.count * _dayCellWidth,
            height: _rowHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              color: AppColors.surface,
            ),
            child: Text(group.label, style: theme.textTheme.bodySmall),
          ),
        )
        .toList();
  }

  List<Widget> _buildDayOfWeekHeaders(ThemeData theme) {
    return _visibleDays
        .map(
          (date) => Container(
            width: _dayCellWidth,
            height: _rowHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
            child: Text(_dayLabel(date), style: theme.textTheme.bodySmall),
          ),
        )
        .toList();
  }

  List<Widget> _buildDayNumberHeaders(ThemeData theme) {
    return _visibleDays
        .map(
          (date) => Container(
            width: _dayCellWidth,
            height: _rowHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
            child: Text('${date.day}', style: theme.textTheme.labelSmall),
          ),
        )
        .toList();
  }

  Widget _buildScrollableGrid(ThemeData theme) {
    final habits = ref.watch(habitBoardProvider);
    final gridHeight = (MediaQuery.of(context).size.height * 0.45).clamp(300.0, 520.0);

    return SizedBox(
      height: gridHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _leftColumnWidth,
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Container(
                  height: _rowHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${habit.name} ${habit.emoji}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(habit.scheduleLabel, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(habitBoardProvider.notifier).removeHabit(habit.id),
                        icon: const Icon(Icons.delete, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _gridHorizontalController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: _visibleDays.length * _dayCellWidth,
                child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) => _buildHabitRow(theme, habits[index]),
                ),
              ),
            ),
          ),
          SizedBox(
            width: _summaryColumnWidth,
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return Container(
                  height: _rowHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${(_habitProgressRatio(habit) * 100).round()}%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        child: Container(
                          width: 72,
                          height: 8,
                          color: AppColors.surface,
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _habitProgressRatio(habit),
                            child: Container(color: AppColors.primaryButtonBlue),
                          ),
                        ),
                      ),
                      if (_filterMode == FilterMode.week) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text('Week ${(_habitProgressRatioForWeek(habit) * 100).round()}%', style: theme.textTheme.bodySmall),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitRow(ThemeData theme, TrackedHabit habit) {
    return Row(
      children: _visibleDays.map((date) {
        final active = _habitActiveOn(habit, date);
        final checked = habit.completions[_dateKey(date)] ?? false;
        return Container(
          width: _dayCellWidth,
          height: _rowHeight,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border), right: BorderSide(color: AppColors.border))),
          child: Center(
            child: active
                ? SizedBox(
                    width: 28,
                    height: 28,
                    child: _squareCheck(
                      checked: checked,
                      onTap: () => ref.read(habitBoardProvider.notifier).toggleCompletion(habit.id, _dateKey(date)),
                    ),
                  )
                : Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSleepRow(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hours of Sleep', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _leftColumnWidth,
              child: Text('Sleep per day', style: theme.textTheme.bodyMedium),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _gridHorizontalController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _visibleDays.map((date) {
                    final key = _dateKey(date);
                    final metric = _dailyMetrics.firstWhere((m) => m.date == key, orElse: () => DailyMetrics(date: key, hoursOfSleep: 0));
                    return Container(
                      width: _dayCellWidth,
                      height: _rowHeight,
                      margin: const EdgeInsets.only(right: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: DropdownButton<int>(
                        value: metric.hoursOfSleep.clamp(0, 24),
                        items: List.generate(25, (i) => DropdownMenuItem(value: i, child: Text('$i', style: theme.textTheme.bodySmall))),
                        onChanged: (v) => _updateSleep(key, (v ?? 0).toString()),
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        iconSize: 18,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _habitProgressRatioForWeek(TrackedHabit habit) {
    final days = _visibleDays.where((d) => _habitActiveOn(habit, d)).toList();
    if (days.isEmpty) return 0;
    final completed = days.where((d) => habit.completions[_dateKey(d)] == true).length;
    return completed / days.length;
  }

  void _showAddHabitDialog() async {
    final nameCtrl = TextEditingController();
    String emoji = '✨';
    bool isPositive = true;
    HabitSchedule selectedSchedule = HabitSchedule.daily;
    final customDays = <int>{};

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(onChanged: (v) => emoji = v, decoration: const InputDecoration(labelText: 'Emoji (optional)')),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Type:'),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Good'), selected: isPositive, onSelected: (_) => setDialogState(() => isPositive = true)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Bad'), selected: !isPositive, onSelected: (_) => setDialogState(() => isPositive = false)),
              ]),
              const SizedBox(height: 16),
              const Text('Schedule', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: HabitSchedule.values.map((option) {
                  return ChoiceChip(
                    label: Text(option.label),
                    selected: selectedSchedule == option,
                    onSelected: (_) {
                      setDialogState(() {
                        selectedSchedule = option;
                        if (option != HabitSchedule.custom) {
                          customDays.clear();
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (selectedSchedule == HabitSchedule.custom) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: List.generate(7, (index) {
                    final weekday = index + 1;
                    const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    final active = customDays.contains(weekday);
                    return FilterChip(
                      label: Text(weekdayLabels[index]),
                      selected: active,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            customDays.add(weekday);
                          } else {
                            customDays.remove(weekday);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final id = DateTime.now().millisecondsSinceEpoch.toString();
                ref.read(habitBoardProvider.notifier).addHabit(
                  TrackedHabit(
                    id: id,
                    name: nameCtrl.text.trim(),
                    emoji: emoji.isEmpty ? '✨' : emoji,
                    isPositive: isPositive,
                    schedule: selectedSchedule,
                    customDays: selectedSchedule == HabitSchedule.custom ? customDays : const {},
                  ),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCountHistogram(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Habit Count / Daily Progress', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: _leftColumnWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Habit Count', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Daily completion histogram', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: dailyCompletedCounts.map((count) {
                    final barHeight = (count / maxDailyCompleted) * 120;
                    return Container(
                      width: _dayCellWidth,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('$count', style: theme.textTheme.bodySmall),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            width: 16,
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: AppColors.primaryButtonBlue,
                              borderRadius: BorderRadius.circular(AppRadius.small),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartsSection(ThemeData theme) {
    final overallProgress = monthlyProgress;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SoftCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Progress Trend', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 180,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 0.5)),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      minX: 0,
                      maxX: (_days.length - 1).toDouble(),
                      minY: 0,
                      maxY: ref.watch(habitBoardProvider).length.toDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: progressSpots,
                          isCurved: true,
                          barWidth: 3,
                          dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: AppColors.primaryMedium.withValues(alpha: 0.24)),
                          color: AppColors.primaryButtonBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 280,
          child: Column(
            children: [
              SoftCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sleep Trend', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 140,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 0.5)),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(show: false),
                          minX: 0,
                          maxX: (_days.length - 1).toDouble(),
                          minY: 0,
                          maxY: 12,
                          lineBarsData: [
                            LineChartBarData(
                              spots: sleepSpots,
                              isCurved: true,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: true, color: AppColors.accentMint.withValues(alpha: 0.24)),
                              color: AppColors.primaryMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SoftCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  children: [
                    Text('Monthly Completion', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 50,
                          sectionsSpace: 0,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: overallProgress * 100,
                              color: AppColors.primaryButtonBlue,
                              radius: 56,
                              title: '${(overallProgress * 100).round()}%',
                              titleStyle: theme.textTheme.titleLarge,
                              titlePositionPercentageOffset: 0.55,
                            ),
                            PieChartSectionData(
                              value: (1 - overallProgress) * 100,
                              color: AppColors.surface,
                              radius: 56,
                              title: '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Habit model is provided by `habit_provider.TractedHabit` via Riverpod.

class DailyMetrics {
  final String date;
  final int hoursOfSleep;

  DailyMetrics({required this.date, required this.hoursOfSleep});
}

class WeekGroup {
  final String label;
  final int count;

  WeekGroup({required this.label, required this.count});
}

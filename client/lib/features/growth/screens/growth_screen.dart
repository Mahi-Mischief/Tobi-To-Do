import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/providers/dream_me_provider.dart';
import 'package:tobi_todo/shared/services/tobi_service.dart';
import 'package:tobi_todo/providers/gamification_provider.dart';

class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({super.key});

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  final _diaryController = TextEditingController();
  final _notesController = TextEditingController();
  final List<TextEditingController> _gratitudeControllers = List.generate(3, (_) => TextEditingController());
  double _mood = 5;
  DateTime _journalDate = DateTime.now();
  final Map<String, _JournalEntry> _journalByDay = {};

  @override
  void dispose() {
    _diaryController.dispose();
    _notesController.dispose();
    for (final c in _gratitudeControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(leaderboardProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                '📈 Your Growth',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track your personal development journey',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Key Metrics
              _buildKeyMetrics(context, leaderboard),
              const SizedBox(height: 24),

              // Notes & Journaling
              _buildJournalSection(context),
              const SizedBox(height: 24),

              // Goals & Habits Section
              _buildGoalsSection(context),
              const SizedBox(height: 24),

              // Dream Me Section
              _buildDreamMeSection(context, ref),
              const SizedBox(height: 24),

              // Analytics
              _buildAnalyticsSection(context),
              const SizedBox(height: 24),

              // Personal Development
              _buildPersonalDevelopmentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, AsyncValue<dynamic> leaderboard) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard('Completion', '85%', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('This Week', '12 tasks', Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard('Streak', '7 days', Colors.orange),
        ),
      ],
    );
  }

  Widget _buildJournalSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📝 Notes & Journaling',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Chip(label: Text('Mood ${_mood.toStringAsFixed(1)}/10')),
                    Text(DateFormat('EEE, MMM d').format(_journalDate), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _journalDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _journalDate = picked;
                        _loadEntryForDay(picked);
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text('Pick a day'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Previous day',
                  onPressed: () {
                    setState(() {
                      _journalDate = _journalDate.subtract(const Duration(days: 1));
                      _loadEntryForDay(_journalDate);
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Next day',
                  onPressed: () {
                    setState(() {
                      _journalDate = _journalDate.add(const Duration(days: 1));
                      _loadEntryForDay(_journalDate);
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Diary for today', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _diaryController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'How did the day feel? What stood out?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Mood', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            Slider(
              value: _mood,
              min: 1,
              max: 10,
              divisions: 18,
              label: _mood.toStringAsFixed(1),
              onChanged: (value) => setState(() => _mood = value),
            ),
            const SizedBox(height: 12),
            Text('Notes — don’t forget', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Capture ideas, work-in-progress thoughts, or reminders',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Gratitude (3+ items)', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._gratitudeControllers
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.favorite_border),
                        labelText: 'Gratitude ${entry.key + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _gratitudeControllers.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: const Text('Add another'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _saveEntry();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Journal saved for ${DateFormat('MMM d').format(_journalDate)}')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save entry'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    _clearInputs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cleared ${DateFormat('MMM d').format(_journalDate)} entry')),
                    );
                  },
                  icon: const Icon(Icons.backspace),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎯 Active Goals',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    TobiService.instance.think();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('See all goals — not implemented yet')));
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGoalItem('Learn Flutter Advanced Patterns', 0.65),
            _buildGoalItem('Complete Project Management Course', 0.40),
            _buildGoalItem('Build 3 Mobile Apps', 0.25),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String title, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamMeSection(BuildContext context, WidgetRef ref) {
    final alignment = ref.watch(alignmentScoreProvider);
    final profileCompletion = ref.watch(profileCompletionProvider);

    return Card(
      elevation: 2,
      color: AppColors.primary.withAlpha((0.1 * 255).round()),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✨ Dream Me', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/dream-me');
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Identity alignment', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Chip(label: Text('$profileCompletion% ready')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  alignment.when(
                    data: (data) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alignment score: ${data.score}/100'),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: data.score / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text('Habits consistency: ${data.breakdown['habitConsistency']?.round() ?? 0}'),
                        Text('Goal momentum: ${data.breakdown['goalCount']?.round() ?? 0}'),
                      ],
                    ),
                    loading: () => const Text('Loading alignment...'),
                    error: (e, _) => Text('Alignment unavailable: $e'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap edit to refine your identity statements, mental contrasting, and monthly reflections.',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 Analytics & Reports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push('/analytics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open Analytics & Reports'),
              ),
            ),
            const SizedBox(height: 16),
            _buildAnalyticsItem('Most Productive Day', 'Tuesday', '🔥'),
            _buildAnalyticsItem('Average Focus Time', '2h 30m', '⏱️'),
            _buildAnalyticsItem('Tasks Completed This Month', '42', '✅'),
            _buildAnalyticsItem('Personal Best Streak', '28 days', '🎯'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDevelopmentSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌟 Personal Development',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDevItem('Skills to Master', ['Advanced Dart', 'System Design', 'Leadership']),
            const SizedBox(height: 12),
            _buildDevItem('Habits to Build', ['Morning Exercise', 'Deep Work', 'Reflection']),
            const SizedBox(height: 12),
            _buildDevItem('Books to Read', ['Clean Code', 'Atomic Habits', 'The Pragmatic Programmer']),
          ],
        ),
      ),
    );
  }

  Widget _buildDevItem(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items
              .map((item) => Chip(
                label: Text(item),
                backgroundColor: AppColors.primary.withAlpha((0.2 * 255).round()),
              ))
              .toList(),
        ),
      ],
    );
  }

  void _saveEntry() {
    final key = _dayKey(_journalDate);
    _journalByDay[key] = _JournalEntry(
      diary: _diaryController.text.trim(),
      notes: _notesController.text.trim(),
      gratitude: _gratitudeControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList(),
      mood: _mood,
    );
  }

  void _loadEntryForDay(DateTime day) {
    final entry = _journalByDay[_dayKey(day)];
    if (entry == null) {
      _clearInputs();
      return;
    }
    _diaryController.text = entry.diary;
    _notesController.text = entry.notes;
    _mood = entry.mood;
    // Rebuild gratitude controllers to fit stored list length (min 3).
    final desired = entry.gratitude.isEmpty ? 3 : entry.gratitude.length;
    if (_gratitudeControllers.length < desired) {
      final addCount = desired - _gratitudeControllers.length;
      for (int i = 0; i < addCount; i++) {
        _gratitudeControllers.add(TextEditingController());
      }
    }
    for (var i = 0; i < _gratitudeControllers.length; i++) {
      _gratitudeControllers[i].text = i < entry.gratitude.length ? entry.gratitude[i] : '';
    }
    setState(() {});
  }

  void _clearInputs() {
    _diaryController.clear();
    _notesController.clear();
    _mood = 5;
    for (final c in _gratitudeControllers) {
      c.clear();
    }
    setState(() {});
  }

  String _dayKey(DateTime day) => '${day.year}-${day.month}-${day.day}';
}

class _JournalEntry {
  final String diary;
  final String notes;
  final List<String> gratitude;
  final double mood;

  _JournalEntry({
    required this.diary,
    required this.notes,
    required this.gratitude,
    required this.mood,
  });
}


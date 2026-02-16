import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';
import 'package:tobi_todo/providers/gamification_provider.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

              // Goals & Habits Section
              _buildGoalsSection(context),
              const SizedBox(height: 24),

              // Dream Me Section
              _buildDreamMeSection(context),
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
                  onPressed: () {},
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

  Widget _buildDreamMeSection(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withOpacity(0.1),
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
                  onPressed: () {},
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'In 5 years, I want to be:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('A senior mobile developer leading innovation in emerging tech'),
                  SizedBox(height: 12),
                  Text('Steps to get there:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Master advanced Flutter & Dart patterns'),
                  Text('• Contribute to open-source projects'),
                  Text('• Build 5+ production apps'),
                  Text('• Mentor junior developers'),
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
                backgroundColor: AppColors.primary.withOpacity(0.2),
              ))
              .toList(),
        ),
      ],
    );
  }
}


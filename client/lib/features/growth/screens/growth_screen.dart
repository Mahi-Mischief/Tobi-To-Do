import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/core/theme/app_theme.dart';
import 'package:tobi_todo/providers/gamification_provider.dart';

class GrowthScreen extends ConsumerWidget {
  const GrowthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final achievements = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Growth'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Overview
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _AnalyticsCard(
              title: 'Completion Rate',
              value: '85%',
              trend: '↑ 5% this week',
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 12),
            _AnalyticsCard(
              title: 'This Week',
              value: '12 tasks',
              trend: '↑ 2 more than last week',
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            _AnalyticsCard(
              title: 'Streak',
              value: '7 days',
              trend: '🔥 On fire!',
              color: AppTheme.warningColor,
            ),
            const SizedBox(height: 24),

            // Leaderboard
            Text(
              'Leaderboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            leaderboard.when(
              data: (rankings) => Column(
                children: rankings.take(5).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final user = entry.value;
                  return _LeaderboardEntry(
                    rank: index + 1,
                    name: user['email'] ?? 'User',
                    xp: user['xp'] ?? 0,
                    isYou: false,
                  );
                }).toList(),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            // Achievements
            Text(
              'Achievements (${_achievements.where((a) => a['unlocked'] == true).length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return _AchievementTile(achievement: achievement);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

final _achievements = [
  {'emoji': '🚀', 'name': 'First Step', 'unlocked': true},
  {'emoji': '🔥', 'name': 'On Fire', 'unlocked': true},
  {'emoji': '⭐', 'name': 'Leveled Up', 'unlocked': false},
  {'emoji': '🎯', 'name': 'Goal Crusher', 'unlocked': false},
  {'emoji': '🧠', 'name': 'Focus Master', 'unlocked': true},
  {'emoji': '✨', 'name': 'Dream Started', 'unlocked': false},
];

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isYou;

  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isYou,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isYou ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$xp XP',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Map<String, dynamic> achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement['unlocked'] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: unlocked
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? AppTheme.primaryColor : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement['emoji'] ?? '🏆',
            style: TextStyle(fontSize: unlocked ? 32 : 24),
          ),
          const SizedBox(height: 8),
          Text(
            achievement['name'] ?? 'Achievement',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: unlocked ? Colors.black : Colors.grey,
            ),
          ),
          if (!unlocked)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.lock_outline, size: 16, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Goals',
              style: AppTypography.heading2,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Dream Me (Long-term goals)',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            if (dreamGoals.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Text(
                  'No dream goals yet. Create one to inspire yourself!',
                  style: AppTypography.bodyMedium,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dreamGoals.length,
                itemBuilder: (context, index) {
                  final goal = dreamGoals[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: AppTypography.heading3,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.small),
                            child: LinearProgressIndicator(
                              value: goal.progressPercentage / 100,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${goal.progressPercentage}% Complete',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analytics',
              style: AppTypography.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('This Week'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.small),
                          ),
                          child: const Text('📈 +23%'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // TODO: Add chart widget
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: const Center(
                        child: Text('Chart coming soon...'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create goal screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tobi_todo/core/theme/app_colors.dart';

/// Simple AI Insights Widget - Displays Tobi AI recommendations
class AIInsightsWidget extends StatelessWidget {
  final Map<String, dynamic>? currentMetrics;
  final Map<String, dynamic>? dreamMetrics;

  const AIInsightsWidget({
    Key? key,
    this.currentMetrics,
    this.dreamMetrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Motivational Section
          _buildMotivationalCard(context),
          const SizedBox(height: 16),

          // Suggestions Section
          _buildSuggestionsCard(context),
          const SizedBox(height: 16),

          // AI Features Quick Access
          _buildAIFeaturesGrid(context),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💪 Motivational Message',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '🚀 You\'ve completed 85% of your tasks this week! Keep pushing to reach 100%. Your consistency is building amazing habits!',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💡 Tobi\'s Suggestions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSuggestionItem('📌 Break your "Learn Advanced Patterns" goal into smaller tasks'),
            _buildSuggestionItem('⏱️ You focus best on Tuesdays - schedule important tasks then'),
            _buildSuggestionItem('🎯 Try a 50-minute focus session instead of 25-min pomodoros'),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✓ ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildAIFeaturesGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🤖 AI Features',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildFeatureCard('🎯 Task Breakdown', 'Break complex tasks into steps'),
            _buildFeatureCard('📅 Semester Plan', 'Plan your entire semester'),
            _buildFeatureCard('⏱️ Time Estimate', 'AI estimates task duration'),
            _buildFeatureCard('🔍 Gap Analysis', 'Identify improvement areas'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                description,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

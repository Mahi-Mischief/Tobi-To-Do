import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// Models for analytics
class AnalyticsDashboard {
  final int taskCompletionRate;
  final int habitConsistency;
  final Map<String, dynamic> weeklySummary;
  final Map<String, dynamic>? mostProductiveTime;
  final List<dynamic> habitPerformance;

  AnalyticsDashboard({
    required this.taskCompletionRate,
    required this.habitConsistency,
    required this.weeklySummary,
    this.mostProductiveTime,
    required this.habitPerformance,
  });

  factory AnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return AnalyticsDashboard(
      taskCompletionRate: json['taskCompletionRate'] ?? 0,
      habitConsistency: json['habitConsistency'] ?? 0,
      weeklySummary: json['weeklySummary'] ?? {},
      mostProductiveTime: json['mostProductiveTime'],
      habitPerformance: json['habitPerformance'] ?? [],
    );
  }
}

class GoalTrend {
  final DateTime date;
  final int completionRate;
  final int completed;
  final int total;

  GoalTrend({
    required this.date,
    required this.completionRate,
    required this.completed,
    required this.total,
  });

  factory GoalTrend.fromJson(Map<String, dynamic> json) {
    return GoalTrend(
      date: DateTime.parse(json['date']),
      completionRate: json['completionRate'] ?? 0,
      completed: json['completed'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class EngagementMetrics {
  final int totalTasks;
  final int totalHabits;
  final int totalGoals;
  final double avgTasksPerDay;
  final int activeLastMonth;

  EngagementMetrics({
    required this.totalTasks,
    required this.totalHabits,
    required this.totalGoals,
    required this.avgTasksPerDay,
    required this.activeLastMonth,
  });

  factory EngagementMetrics.fromJson(Map<String, dynamic> json) {
    return EngagementMetrics(
      totalTasks: json['totalTasks'] ?? 0,
      totalHabits: json['totalHabits'] ?? 0,
      totalGoals: json['totalGoals'] ?? 0,
      avgTasksPerDay: (json['avgTasksPerDay'] ?? 0).toDouble(),
      activeLastMonth: json['activeLastMonth'] ?? 0,
    );
  }
}

// Provider for analytics dashboard
final analyticsDashboardProvider = FutureProvider<AnalyticsDashboard>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/dashboard');
  return AnalyticsDashboard.fromJson(response);
});

// Provider for task completion rate
final taskCompletionRateProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/completion-rate?days=30');
  return response['completionRate'] ?? 0;
});

// Provider for habit consistency
final habitConsistencyAnalyticsProvider = FutureProvider<int>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/habit-consistency?days=7');
  return response['consistency'] ?? 0;
});

// Provider for goal trends
final goalTrendsProvider = FutureProvider<List<GoalTrend>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/goal-trends?days=90');
  return (response as List).map((e) => GoalTrend.fromJson(e)).toList();
});

// Provider for engagement metrics
final engagementMetricsProvider = FutureProvider<EngagementMetrics>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/engagement');
  return EngagementMetrics.fromJson(response);
});

// Provider for productivity heatmap
final productivityHeatmapProvider = FutureProvider<List<List<int>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/productivity-heatmap?weeks=4');
  final heatmap = response['heatmap'] as List;
  return heatmap.map((row) => List<int>.from(row as List)).toList();
});

// Provider for daily focus time
final dailyFocusTimeProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/analytics/focus-time?days=30');
  return List<Map<String, dynamic>>.from(response);
});

// Provider for most productive time
final mostProductiveTimeProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.get('/analytics/productive-time?days=30');
});

// Provider for weekly summary
final weeklySummaryProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.get('/analytics/weekly-summary');
});

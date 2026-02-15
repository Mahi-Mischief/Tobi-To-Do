import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/services/api_client.dart';

// API Client Provider
final apiClientProvider = Provider((ref) => ApiClient());

// Models for focus
class FocusSession {
  final String id;
  final String? taskId;
  final int durationMinutes;
  final bool wasCompleted;
  final DateTime? completedAt;
  final DateTime createdAt;

  FocusSession({
    required this.id,
    this.taskId,
    required this.durationMinutes,
    required this.wasCompleted,
    this.completedAt,
    required this.createdAt,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'],
      taskId: json['task_id'],
      durationMinutes: json['duration_minutes'],
      wasCompleted: json['was_completed'] ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class FocusStats {
  final int totalSessions;
  final int completedSessions;
  final int totalMinutes;
  final double avgDuration;
  final double completionRate;

  FocusStats({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalMinutes,
    required this.avgDuration,
    required this.completionRate,
  });

  factory FocusStats.fromJson(Map<String, dynamic> json) {
    return FocusStats(
      totalSessions: json['totalSessions'] ?? 0,
      completedSessions: json['completedSessions'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      avgDuration: (json['avgDuration'] ?? 0).toDouble(),
      completionRate: (json['completionRate'] ?? 0).toDouble(),
    );
  }
}

class BurnoutInfo {
  final String level; // none, mild, moderate, severe
  final int score;
  final List<String> factors;
  final List<String> recommendations;

  BurnoutInfo({
    required this.level,
    required this.score,
    required this.factors,
    required this.recommendations,
  });

  factory BurnoutInfo.fromJson(Map<String, dynamic> json) {
    return BurnoutInfo(
      level: json['burnoutLevel'] ?? 'none',
      score: json['burnoutScore'] ?? 0,
      factors: List<String>.from(json['factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

// Notifier for active focus session timer
class ActiveFocusNotifier extends StateNotifier<FocusSession?> {
  ActiveFocusNotifier(this._apiClient) : super(null);

  final ApiClient _apiClient;
  Timer? _timer;

  // Start a focus session
  Future<FocusSession> startSession({
    String? taskId,
    required int durationMinutes,
  }) async {
    try {
      final response = await _apiClient.post('/focus/start', {
        'taskId': taskId,
        'durationMinutes': durationMinutes,
      }) as Map<String, dynamic>;
      final session = FocusSession.fromJson(response);
      state = session;
      _startTimer(session, durationMinutes);
      return session;
    } catch (e) {
      rethrow;
    }
  }

  // End focus session
  Future<FocusSession> endSession(bool completed) async {
    try {
      if (state == null) throw Exception('No active session');

      _timer?.cancel();
      final response = await _apiClient.post('/focus/${state!.id}/end', {
        'completed': completed,
      }) as Map<String, dynamic>;
      final session = FocusSession.fromJson(response);
      state = null;
      return session;
    } catch (e) {
      rethrow;
    }
  }

  // Internal timer management
  void _startTimer(FocusSession session, int durationMinutes) {
    final startTime = DateTime.now();
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = endTime.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Provider for active focus session
final activeFocusProvider = StateNotifierProvider<ActiveFocusNotifier, FocusSession?>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ActiveFocusNotifier(apiClient);
});

// Provider for focus history
final focusHistoryProvider = FutureProvider<List<FocusSession>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/focus/history');
  return (response as List).map((e) => FocusSession.fromJson(e as Map<String, dynamic>)).toList();
});

// Provider for focus stats
final focusStatsProvider = FutureProvider<FocusStats>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/focus/stats') as Map<String, dynamic>;
  return FocusStats.fromJson(response);
});

// Provider for burnout detection
final burnoutInfoProvider = FutureProvider<BurnoutInfo>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/focus/burnout/detect') as Map<String, dynamic>;
  return BurnoutInfo.fromJson(response);
});

// Provider for focus streak
final focusStreakProvider = FutureProvider<int>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.get('/focus/streak') as Map<String, dynamic>;
  return response['streak'] as int? ?? 0;
});

// Derived provider for remaining focus time
final remainingFocusTimeProvider = Provider<int>((ref) {
  final session = ref.watch(activeFocusProvider);
  if (session == null) return 0;

  final elapsed = DateTime.now().difference(session.createdAt).inMinutes;
  return (session.durationMinutes - elapsed).clamp(0, session.durationMinutes);
});

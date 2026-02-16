import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simplified AI Providers for Tobi AI features
/// These can be enhanced later when backend is fully ready

/// Example AI Insight Provider
final aiInsightProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Simulate AI insight loading
  await Future.delayed(const Duration(seconds: 1));
  return {
    'suggestion': '💡 Break down your big tasks into smaller steps',
    'priority': 'high',
    'category': 'productivity',
  };
});

/// Example Task Breakdown Provider  
final taskBreakdownProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, taskTitle) async {
  await Future.delayed(const Duration(seconds: 1));
  return {
    'subtasks': ['Step 1', 'Step 2', 'Step 3'],
    'estimatedTime': '2 hours',
  };
});

/// Example Motivational Message Provider
final motivationalMessageProvider = FutureProvider<String>((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return '🚀 You\'ve got this! Keep pushing forward!';
});

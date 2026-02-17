import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/goal_model.dart';

// Mock goals data
// Minimal goals providers (shims) to satisfy analyzer. Replace with full implementation later.
final goalsProvider = Provider<AsyncValue<List<Goal>>>((ref) {
  return const AsyncValue.data([]);
});

final activeGoalsProvider = Provider<List<Goal>>((ref) {
  return [];
});

final dreamGoalsProvider = Provider<List<Goal>>((ref) {
  return [];
});

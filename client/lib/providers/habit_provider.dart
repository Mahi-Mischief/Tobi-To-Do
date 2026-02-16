import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_model.dart';
import '../services/api_client.dart';

final apiClientProvider = Provider((ref) => ApiClient());

// Simple provider for habits (mock data for now)
final habitsProvider = Provider<List<Habit>>((ref) {
  return [];
});

// Provider for habit stats
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return {'total': 0, 'completed': 0, 'streak': 0};
});

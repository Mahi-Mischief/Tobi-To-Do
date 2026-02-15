import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_model.dart';
import '../services/api_client.dart';

// State notifier for habits
class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier(this.ref) : super([]);

  final Ref ref;

  // Fetch all habits
  Future<void> fetchHabits() async {
    try {
      final response = await ApiClient.get('/habits');
      final habits = (response as List)
          .map((e) => Habit.fromJson(e))
          .toList();
      state = habits;
    } catch (e) {
      rethrow;
    }
  }

  // Create new habit
  Future<Habit> createHabit({
    required String name,
    required String frequency,
    String? description,
  }) async {
    try {
      final response = await ApiClient.post('/habits', {
        'name': name,
        'frequency': frequency,
        'description': description,
      });
      final habit = Habit.fromJson(response);
      state = [...state, habit];
      return habit;
    } catch (e) {
      rethrow;
    }
  }

  // Update habit
  Future<Habit> updateHabit(String habitId, Map<String, dynamic> updates) async {
    try {
      final response = await ApiClient.patch('/habits/$habitId', updates);
      final updatedHabit = Habit.fromJson(response);
      state = [
        for (final habit in state)
          if (habit.id == habitId) updatedHabit else habit
      ];
      return updatedHabit;
    } catch (e) {
      rethrow;
    }
  }

  // Complete habit (mark as done for today)
  Future<Habit> completeHabit(String habitId) async {
    try {
      final response = await ApiClient.post('/habits/$habitId/complete', {});
      final updatedHabit = Habit.fromJson(response);
      state = [
        for (final habit in state)
          if (habit.id == habitId) updatedHabit else habit
      ];
      return updatedHabit;
    } catch (e) {
      rethrow;
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await ApiClient.delete('/habits/$habitId');
      state = state.where((h) => h.id != habitId).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Reset streak
  Future<Habit> resetStreak(String habitId) async {
    try {
      final response = await ApiClient.post('/habits/$habitId/reset-streak', {});
      final updatedHabit = Habit.fromJson(response);
      state = [
        for (final habit in state)
          if (habit.id == habitId) updatedHabit else habit
      ];
      return updatedHabit;
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for all habits
final habitsProvider = StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier(ref);
});

// Provider for habits due today
final habitsDueTodayProvider = FutureProvider<List<Habit>>((ref) async {
  final response = await ApiClient.get('/habits/due-today');
  return (response as List).map((e) => Habit.fromJson(e)).toList();
});

// Provider for habit stats
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await ApiClient.get('/habits/stats');
});

// Provider for habit consistency
final habitConsistencyProvider = FutureProvider<int>((ref) async {
  final response = await ApiClient.get('/habits/consistency');
  return response['consistency'] ?? 0;
});

// Derived provider for active habits (with streak > 0)
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  final habits = ref.watch(habitsProvider);
  return habits.where((h) => h.streakCount > 0).toList();
});

// Derived provider for habit count by frequency
final habitCountByFrequencyProvider = Provider<Map<String, int>>((ref) {
  final habits = ref.watch(habitsProvider);
  final count = <String, int>{};
  for (final habit in habits) {
    count[habit.frequency] = (count[habit.frequency] ?? 0) + 1;
  }
  return count;
});

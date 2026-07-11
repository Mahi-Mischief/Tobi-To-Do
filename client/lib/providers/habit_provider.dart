import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Local lightweight tracked habit used for UI checkboxes and daily completions
enum HabitSchedule { daily, weekdays, weekends, custom }

extension HabitScheduleLabel on HabitSchedule {
  String get label {
    switch (this) {
      case HabitSchedule.daily:
        return 'Daily';
      case HabitSchedule.weekdays:
        return 'Weekdays';
      case HabitSchedule.weekends:
        return 'Weekends';
      case HabitSchedule.custom:
        return 'Custom';
    }
  }
}

class TrackedHabit {
  final String id;
  final String name;
  final String emoji;
  final bool isPositive;
  final HabitSchedule schedule;
  final Set<int> customDays;
  final Map<String, bool> completions;

  TrackedHabit({
    required this.id,
    required this.name,
    required this.emoji,
    Map<String, bool>? completions,
    this.isPositive = true,
    this.schedule = HabitSchedule.daily,
    Set<int>? customDays,
  })  : completions = completions ?? {},
        customDays = customDays ?? const {};

  TrackedHabit copyWith({
    String? name,
    String? emoji,
    bool? isPositive,
    HabitSchedule? schedule,
    Set<int>? customDays,
    Map<String, bool>? completions,
  }) {
    return TrackedHabit(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      isPositive: isPositive ?? this.isPositive,
      schedule: schedule ?? this.schedule,
      customDays: customDays ?? Set<int>.from(this.customDays),
      completions: completions ?? Map<String, bool>.from(this.completions),
    );
  }

  bool isActiveOn(DateTime date) {
    final weekday = date.weekday;
    switch (schedule) {
      case HabitSchedule.daily:
        return true;
      case HabitSchedule.weekdays:
        return weekday >= DateTime.monday && weekday <= DateTime.friday;
      case HabitSchedule.weekends:
        return weekday == DateTime.saturday || weekday == DateTime.sunday;
      case HabitSchedule.custom:
        return customDays.contains(weekday);
    }
  }

  String get scheduleLabel {
    if (schedule != HabitSchedule.custom) {
      return schedule.label;
    }
    if (customDays.isEmpty) {
      return 'Custom';
    }
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return customDays.map((day) => names[day - 1]).join(', ');
  }
}

final habitBoardProvider = NotifierProvider<HabitBoardNotifier, List<TrackedHabit>>(HabitBoardNotifier.new);

class HabitBoardNotifier extends Notifier<List<TrackedHabit>> {
  static const _prefsHabitsKey = 'habits_board_v1';
  bool _loaded = false;

  @override
  List<TrackedHabit> build() {
    return [
      TrackedHabit(id: 'h1', name: 'Wake up at 05:00', emoji: '⏰', isPositive: true),
      TrackedHabit(id: 'h2', name: 'Gym', emoji: '💪', isPositive: true),
      TrackedHabit(id: 'h3', name: 'Reading / Learning', emoji: '📖', isPositive: true),
      TrackedHabit(id: 'h5', name: 'No Gooning', emoji: '🚫', isPositive: false),
    ];
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsHabitsKey);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        state = list.map((e) {
          final map = Map<String, dynamic>.from(e as Map);
          final id = map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
          final name = map['name'] as String? ?? '';
          final emoji = map['emoji'] as String? ?? '✨';
          final isPositive = map['is_positive'] as bool? ?? true;
          final scheduleStr = map['schedule'] as String? ?? 'daily';
          final schedule = HabitSchedule.values.firstWhere((s) => s.toString().split('.').last == scheduleStr, orElse: () => HabitSchedule.daily);
          final customDaysRaw = map['custom_days'] as List<dynamic>? ?? [];
          final customDays = customDaysRaw.map((d) => (d as num).toInt()).toSet();
          final completionsRaw = map['completions'] as Map<String, dynamic>? ?? {};
          final completions = completionsRaw.map((k, v) => MapEntry(k, v == true));
          return TrackedHabit(id: id, name: name, emoji: emoji, isPositive: isPositive, completions: Map<String, bool>.from(completions), schedule: schedule, customDays: customDays);
        }).toList();
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load persisted habits: $e');
    }
    _loaded = true;
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = state
          .map((h) => {
                'id': h.id,
                'name': h.name,
                'emoji': h.emoji,
                'is_positive': h.isPositive,
                'schedule': h.schedule.toString().split('.').last,
                'custom_days': h.customDays.toList(),
                'completions': h.completions,
              })
          .toList();
      await prefs.setString(_prefsHabitsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('⚠️ Failed to persist habits locally: $e');
    }
  }

  Future<void> addHabit(TrackedHabit habit) async {
    state = [...state, habit];
    _saveToPrefs();
    try {
      await ref.read(apiClientProvider).post('/habits', {
        'id': habit.id,
        'name': habit.name,
        'emoji': habit.emoji,
        'is_positive': habit.isPositive,
        'schedule': habit.schedule.toString().split('.').last,
        'custom_days': habit.customDays.toList(),
        'completions': habit.completions,
      });
    } catch (e) {
      debugPrint('⚠️ Failed to persist habit: $e');
    }
  }

  Future<void> removeHabit(String id) async {
    state = state.where((h) => h.id != id).toList();
    _saveToPrefs();
    try {
      await ref.read(apiClientProvider).delete('/habits/$id');
    } catch (e) {
      debugPrint('⚠️ Failed to delete habit: $e');
    }
  }

  Future<void> toggleCompletion(String habitId, String dateKey) async {
    state = state.map((h) {
      if (h.id != habitId) return h;
      final updated = Map<String, bool>.from(h.completions);
      updated[dateKey] = !(updated[dateKey] ?? false);
      return h.copyWith(completions: updated);
    }).toList();
    _saveToPrefs();
    try {
      await ref.read(apiClientProvider).patch('/habits/$habitId', {
        'completions': state.firstWhere((h) => h.id == habitId).completions,
      });
    } catch (e) {
      debugPrint('⚠️ Failed to persist habit completion: $e');
    }
  }

  Future<void> setCompletion(String habitId, String dateKey, bool value) async {
    state = state.map((h) {
      if (h.id != habitId) return h;
      final updated = Map<String, bool>.from(h.completions);
      updated[dateKey] = value;
      return h.copyWith(completions: updated);
    }).toList();
    _saveToPrefs();
    try {
      await ref.read(apiClientProvider).patch('/habits/$habitId', {
        'completions': state.firstWhere((h) => h.id == habitId).completions,
      });
    } catch (e) {
      debugPrint('⚠️ Failed to persist habit completion update: $e');
    }
  }

  void reorderHabits(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _saveToPrefs();
  }
}

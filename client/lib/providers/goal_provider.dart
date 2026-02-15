import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/goal_model.dart';

// Mock goals data
final goalsProvider = StateNotifierProvider<GoalsNotifier, AsyncValue<List<Goal>>>((ref) {
  return GoalsNotifier();
});

class GoalsNotifier extends StateNotifier<AsyncValue<List<Goal>>> {
  GoalsNotifier() : super(const AsyncValue.data([]));

  // TODO: Implement actual API calls for goals
  void addGoal(Goal goal) {
    state.whenData((goals) {
      state = AsyncValue.data([...goals, goal]);
    });
  }

  void updateGoal(Goal goal) {
    state.whenData((goals) {
      final index = goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        goals[index] = goal;
        state = AsyncValue.data([...goals]);
      }
    });
  }

  void removeGoal(String goalId) {
    state.whenData((goals) {
      state = AsyncValue.data(
        goals.where((g) => g.id != goalId).toList(),
      );
    });
  }
}

// Active goals provider
final activeGoalsProvider = Provider((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.maybeWhen(
    data: (goalList) => goalList.where((g) => g.status == GoalStatus.active).toList(),
    orElse: () => [],
  );
});

// Dream goals (long-term goals)
final dreamGoalsProvider = Provider((ref) {
  final goals = ref.watch(goalsProvider);
  return goals.maybeWhen(
    data: (goalList) => goalList.where((g) => g.category == 'dream').toList(),
    orElse: () => [],
  );
});

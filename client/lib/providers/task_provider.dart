import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/task_model.dart';
import 'package:tobi_todo/services/api_client.dart';

final apiClientProvider = Provider((ref) => ApiClient());

// Task list notifier
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final ApiClient apiClient;

  TaskNotifier({required this.apiClient}) : super(const AsyncValue.loading());

  Future<void> fetchTasks({String? status, String? priority}) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await apiClient.getTasks(status: status, priority: priority);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final newTask = await apiClient.createTask(task);
      state.whenData((tasks) {
        state = AsyncValue.data([...tasks, newTask]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(String taskId, Task task) async {
    try {
      final updatedTask = await apiClient.updateTask(taskId, task);
      state.whenData((tasks) {
        final index = tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          tasks[index] = updatedTask;
          state = AsyncValue.data([...tasks]);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await apiClient.deleteTask(taskId);
      state.whenData((tasks) {
        state = AsyncValue.data(
          tasks.where((t) => t.id != taskId).toList(),
        );
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeTask(String taskId) async {
    state.whenData((tasks) {
      final task = tasks.firstWhere((t) => t.id == taskId);
      updateTask(taskId, task.copyWith(completed: true, status: TaskStatus.completed));
    });
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TaskNotifier(apiClient: apiClient);
});

// Dashboard stats provider
final dashboardStatsProvider = FutureProvider((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getDashboardStats();
});

// Completed tasks count
final completedTasksCountProvider = Provider((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.maybeWhen(
    data: (taskList) => taskList.where((t) => t.completed).length,
    orElse: () => 0,
  );
});

// Pending tasks count
final pendingTasksCountProvider = Provider((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.maybeWhen(
    data: (taskList) => taskList.where((t) => !t.completed).length,
    orElse: () => 0,
  );
});

// High priority tasks
final highPriorityTasksProvider = Provider((ref) {
  final tasks = ref.watch(taskProvider);
  return tasks.maybeWhen(
    data: (taskList) => taskList
        .where((t) => t.priority == TaskPriority.high && !t.completed)
        .toList(),
    orElse: () => [],
  );
});

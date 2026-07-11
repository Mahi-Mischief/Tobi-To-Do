import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tobi_todo/models/task_model.dart';
import 'package:tobi_todo/services/api_client.dart';

final apiClientProvider = Provider((ref) => ApiClient());

// Simple task provider (mock data for now)
final taskProvider = Provider<List<Task>>((ref) {
  return [];
});

// Completed tasks count
final completedTasksCountProvider = Provider((ref) {
  return 0;
});

// Pending tasks count
final pendingTasksCountProvider = Provider((ref) {
  return 0;
});

final taskBoardProvider = NotifierProvider<TaskBoardNotifier, List<Task>>(TaskBoardNotifier.new);

class TaskBoardNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return [
          Task(
            id: 't1',
            userId: 'demo',
            title: 'Finish chemistry lab',
            description: 'Lab report submission',
            dueDate: DateTime.now().add(const Duration(hours: 6)),
            priority: TaskPriority.high,
            category: 'school',
            status: TaskStatus.todo,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't2',
            userId: 'demo',
            title: 'Outline history essay',
            description: 'Draft outline',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            priority: TaskPriority.medium,
            category: 'essay',
            status: TaskStatus.inProgress,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't3',
            userId: 'demo',
            title: 'Weekly review',
            description: 'Plan next week',
            dueDate: DateTime.now().add(const Duration(days: 5)),
            priority: TaskPriority.low,
            category: 'planning',
            status: TaskStatus.todo,
            completed: false,
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            updatedAt: DateTime.now(),
          ),
          Task(
            id: 't4',
            userId: 'demo',
            title: 'CS project integration',
            description: 'Merge feature branch',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            priority: TaskPriority.high,
            category: 'project',
            status: TaskStatus.inProgress,
            completed: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
  }

  void setStatus(String id, TaskStatus status) {
    state = state.map((t) => t.id == id ? t.copyWith(status: status, updatedAt: DateTime.now()) : t).toList();
  }

  void toggleStatus(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final next = t.status == TaskStatus.completed
          ? TaskStatus.todo
          : t.status == TaskStatus.todo
              ? TaskStatus.inProgress
              : TaskStatus.completed;
      return t.copyWith(status: next, completed: next == TaskStatus.completed, updatedAt: DateTime.now());
    }).toList();
  }

  void addTask(Task task) {
    state = [...state, task];
    ref.read(apiClientProvider).createTask(task).then((_) {}).catchError((_) {});
  }

  void cycleQuadrant(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final nextPriority = t.priority == TaskPriority.high
          ? TaskPriority.medium
          : t.priority == TaskPriority.medium
              ? TaskPriority.low
              : TaskPriority.high;
      return t.copyWith(priority: nextPriority, updatedAt: DateTime.now());
    }).toList();
  }
}

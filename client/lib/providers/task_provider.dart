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

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, completed }

class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final String category;
  final TaskStatus status;
  final bool completed;
  final DateTime? completedAt;
  final int? durationMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = 'general',
    this.status = TaskStatus.todo,
    this.completed = false,
    this.completedAt,
    this.durationMinutes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      priority: TaskPriority.values.firstWhere(
        (p) => p.toString().split('.').last == (json['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      category: json['category'] as String? ?? 'general',
      status: TaskStatus.values.firstWhere(
        (s) => s.toString().split('.').last == (json['status'] ?? 'todo'),
        orElse: () => TaskStatus.todo,
      ),
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
      durationMinutes: json['duration_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'category': category,
      'status': status.toString().split('.').last,
      'completed': completed,
      'completed_at': completedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    String? category,
    TaskStatus? status,
    bool? completed,
    DateTime? completedAt,
    int? durationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

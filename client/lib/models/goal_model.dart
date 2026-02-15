enum GoalStatus { active, completed, archived }

class Goal {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String category;
  final DateTime? targetDate;
  final int progressPercentage;
  final GoalStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.category = 'personal',
    this.targetDate,
    this.progressPercentage = 0,
    this.status = GoalStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'personal',
      targetDate: json['target_date'] != null ? DateTime.parse(json['target_date'] as String) : null,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      status: GoalStatus.values.firstWhere(
        (s) => s.toString().split('.').last == (json['status'] ?? 'active'),
        orElse: () => GoalStatus.active,
      ),
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
      'category': category,
      'target_date': targetDate?.toIso8601String(),
      'progress_percentage': progressPercentage,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

enum HabitFrequency { daily, weekly, monthly }

class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final HabitFrequency frequency;
  final int streakCount;
  final int bestStreak;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.frequency = HabitFrequency.daily,
    this.streakCount = 0,
    this.bestStreak = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.toString().split('.').last == (json['frequency'] ?? 'daily'),
        orElse: () => HabitFrequency.daily,
      ),
      streakCount: json['streak_count'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
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
      'frequency': frequency.toString().split('.').last,
      'streak_count': streakCount,
      'best_streak': bestStreak,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

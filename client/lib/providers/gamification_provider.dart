import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// Models for gamification
class GamificationStats {
  final int xp;
  final int level;
  final int nextLevelXP;
  final int levelProgress;
  final int achievements;
  final int activeStreaks;

  GamificationStats({
    required this.xp,
    required this.level,
    required this.nextLevelXP,
    required this.levelProgress,
    required this.achievements,
    required this.activeStreaks,
  });

  factory GamificationStats.fromJson(Map<String, dynamic> json) {
    return GamificationStats(
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      nextLevelXP: json['nextLevelXP'] ?? 100,
      levelProgress: json['levelProgress'] ?? 0,
      achievements: json['achievements'] ?? 0,
      activeStreaks: json['activeStreaks'] ?? 0,
    );
  }
}

class Achievement {
  final String achievementType;
  final DateTime earnedAt;

  Achievement({
    required this.achievementType,
    required this.earnedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      achievementType: json['achievement_type'],
      earnedAt: DateTime.parse(json['earned_at']),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String id;
  final String fullName;
  final int xp;
  final int level;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.id,
    required this.fullName,
    required this.xp,
    required this.level,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      id: json['id'],
      fullName: json['full_name'],
      xp: json['xp'],
      level: json['level'],
      avatarUrl: json['avatar_url'],
    );
  }
}

// Provider for gamification stats
final gamificationStatsProvider = FutureProvider<GamificationStats>((ref) async {
  final response = await ApiClient.get('/gamification/stats');
  return GamificationStats.fromJson(response);
});

// Provider for user achievements
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final response = await ApiClient.get('/gamification/achievements');
  return (response as List).map((e) => Achievement.fromJson(e)).toList();
});

// Provider for user rank
final userRankProvider = FutureProvider<int>((ref) async {
  final response = await ApiClient.get('/gamification/rank');
  return response['rank'] ?? 0;
});

// Provider for leaderboard
final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final response = await ApiClient.get('/gamification/leaderboard');
  return (response as List).map((e) => LeaderboardEntry.fromJson(e)).toList();
});

// Derived provider for next milestone XP
final nextMilestoneXpProvider = FutureProvider<int>((ref) async {
  final stats = await ref.watch(gamificationStatsProvider.future);
  return stats.nextLevelXP - stats.xp;
});

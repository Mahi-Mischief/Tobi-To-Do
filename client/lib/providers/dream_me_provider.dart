import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

// Models for Dream Me
class DreamProfile {
  final String id;
  final String userId;
  final String? visionStatement;
  final String? coreValues;
  final String? threeYearGoal;
  final List<String> identityStatements;
  final DateTime createdAt;
  final DateTime updatedAt;

  DreamProfile({
    required this.id,
    required this.userId,
    this.visionStatement,
    this.coreValues,
    this.threeYearGoal,
    required this.identityStatements,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DreamProfile.fromJson(Map<String, dynamic> json) {
    return DreamProfile(
      id: json['id'],
      userId: json['user_id'],
      visionStatement: json['vision_statement'],
      coreValues: json['core_values'],
      threeYearGoal: json['three_year_goal'],
      identityStatements: List<String>.from(json['identityStatements'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class AlignmentScore {
  final int score;
  final Map<String, dynamic> breakdown;

  AlignmentScore({
    required this.score,
    required this.breakdown,
  });

  factory AlignmentScore.fromJson(Map<String, dynamic> json) {
    return AlignmentScore(
      score: json['score'] ?? 0,
      breakdown: json['breakdown'] ?? {},
    );
  }
}

class GapAnalysis {
  final List<String> gaps;
  final List<String> suggestions;
  final int? alignmentScore;

  GapAnalysis({
    required this.gaps,
    required this.suggestions,
    this.alignmentScore,
  });

  factory GapAnalysis.fromJson(Map<String, dynamic> json) {
    return GapAnalysis(
      gaps: List<String>.from(json['gaps'] ?? []),
      suggestions: List<String>.from(json['suggestions'] ?? []),
      alignmentScore: json['alignmentScore'],
    );
  }
}

class Reflection {
  final String id;
  final String content;
  final String? mood;
  final String? insights;
  final DateTime createdAt;

  Reflection({
    required this.id,
    required this.content,
    this.mood,
    this.insights,
    required this.createdAt,
  });

  factory Reflection.fromJson(Map<String, dynamic> json) {
    return Reflection(
      id: json['id'],
      content: json['content'],
      mood: json['mood'],
      insights: json['insights'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// Lightweight provider shim for dream profile to satisfy analyzer.
// Replace with a full implementation later if needed.
final dreamMeProvider = Provider<DreamProfile?>((ref) {
  return null;
});

// Provider for alignment score
final alignmentScoreProvider = FutureProvider<AlignmentScore>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/dream-me/alignment');
  return AlignmentScore.fromJson(response);
});

// Provider for gap analysis
final gapAnalysisProvider = FutureProvider<GapAnalysis>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/dream-me/gaps');
  return GapAnalysis.fromJson(response);
});

// Provider for reflections
final reflectionsProvider = FutureProvider<List<Reflection>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.get('/dream-me/reflections');
  return (response as List).map((e) => Reflection.fromJson(e)).toList();
});

// Provider for Dream Me insights (comprehensive dashboard)
final dreamMeInsightsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.get('/dream-me/insights');
});

// Provider for milestone progress
final milestoneProgressProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.get('/dream-me/milestones');
});

// Derived provider for profile completion percentage
final profileCompletionProvider = Provider<int>((ref) {
  final profile = ref.watch(dreamMeProvider);
  if (profile == null) return 0;

  int completed = 0;
  int total = 4;

  if (profile.visionStatement != null) completed++;
  if (profile.coreValues != null) completed++;
  if (profile.threeYearGoal != null) completed++;
  if (profile.identityStatements.isNotEmpty) completed++;

  return (completed / total * 100).round();
});

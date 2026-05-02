import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int totalXp;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  String createdAt;

  Pet({
    required this.name,
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastUpdated,
    required this.createdAt,
  });

  // Current evolution stage
  Map<String, dynamic> get evolutionStage {
    final stages = AppConstants.evolutionStages;
    Map<String, dynamic> current = stages.first;
    for (final stage in stages) {
      if (totalXp >= (stage['minXp'] as int)) {
        current = stage;
      }
    }
    return current;
  }

  // XP needed for next evolution
  int? get xpToNextStage {
    final stages = AppConstants.evolutionStages;
    for (int i = 0; i < stages.length - 1; i++) {
      if (totalXp < (stages[i + 1]['minXp'] as int)) {
        return (stages[i + 1]['minXp'] as int) - totalXp;
      }
    }
    return null; // Max stage
  }

  // Progress to next evolution (0.0 - 1.0)
  double get evolutionProgress {
    final stages = AppConstants.evolutionStages;
    for (int i = 0; i < stages.length - 1; i++) {
      final currentMin = stages[i]['minXp'] as int;
      final nextMin    = stages[i + 1]['minXp'] as int;
      if (totalXp < nextMin) {
        return (totalXp - currentMin) / (nextMin - currentMin);
      }
    }
    return 1.0;
  }

  // Mood based on today's completion rate
  String getMood(double completionRate) {
    if (completionRate >= AppConstants.moodHappy)   return 'happy';
    if (completionRate >= AppConstants.moodNeutral)  return 'neutral';
    if (completionRate >= AppConstants.moodSad)      return 'sad';
    return 'sick';
  }

  String getMoodEmoji(double completionRate) {
    switch (getMood(completionRate)) {
      case 'happy':   return '😄';
      case 'neutral': return '😐';
      case 'sad':     return '😢';
      case 'sick':    return '🤒';
      default:        return '😐';
    }
  }
}
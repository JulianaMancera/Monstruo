import 'package:hive_flutter/hive_flutter.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  String frequency; // daily, weekdays, weekends

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<String> completedDates; // 'yyyy-MM-dd'

  Habit({
    required this.id,
    required this.title,
    required this.category,
    this.frequency = 'daily',
    this.isActive = true,
    required this.createdAt,
    List<String>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool get isCompletedToday {
    return completedDates.contains(_todayString());
  }

  void completeToday() {
    final today = _todayString();
    if (!completedDates.contains(today)) {
      completedDates.add(today);
      save();
    }
  }

  void uncompleteToday() {
    completedDates.remove(_todayString());
    save();
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date    = now.subtract(Duration(days: i));
      final dateStr = _dateString(date);
      if (completedDates.contains(dateStr)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  int get totalCompletions => completedDates.length;

  String _todayString() => _dateString(DateTime.now());

  String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
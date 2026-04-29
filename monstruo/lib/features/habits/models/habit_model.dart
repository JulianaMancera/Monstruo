import 'package:hive_flutter/hive_flutter.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late int streak;

  @HiveField(4)
  late List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    this.streak = 0,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];
}

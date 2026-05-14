import 'package:hive_flutter/hive_flutter.dart';

part 'entry_model.g.dart';

@HiveType(typeId: 0)
class TimeEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String categoryId;

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  String date; // 'yyyy-MM-dd'

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime createdAt;

  TimeEntry({
    required this.id,
    required this.categoryId,
    required this.durationMinutes,
    required this.date,
    this.note,
    required this.createdAt,
  });
}

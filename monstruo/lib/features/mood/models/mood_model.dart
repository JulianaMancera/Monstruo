import 'package:hive_flutter/hive_flutter.dart';

part 'mood_model.g.dart';

@HiveType(typeId: 2)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String date; // 'yyyy-MM-dd'

  @HiveField(1)
  int score; // 1–5

  @HiveField(2)
  String? note;

  MoodEntry({required this.date, required this.score, this.note});
}

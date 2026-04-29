import 'package:hive_flutter/hive_flutter.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 0)
class Pet extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String species;

  @HiveField(3)
  late int level;

  @HiveField(4)
  late int experience;

  @HiveField(5)
  late int health;

  @HiveField(6)
  late int mood;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.level = 1,
    this.experience = 0,
    this.health = 100,
    this.mood = 100,
  });
}

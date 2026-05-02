import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pet_model.dart';
import '../../habits/providers/habit_provider.dart';
import '../../../core/constants/app_constants.dart';

class PetNotifier extends Notifier<Pet?> {
  Box<Pet> get _box => Hive.box<Pet>(AppConstants.petBox);

  @override
  Pet? build() {
    return _box.isNotEmpty ? _box.getAt(0) : null;
  }

  Future<void> createPet(String name) async {
    final pet = Pet(
      name: name,
      lastUpdated: DateTime.now(),
      createdAt: DateTime.now().toIso8601String(),
    );
    await _box.add(pet);
    state = _box.getAt(0);
  }

  Future<void> awardXp(int amount) async {
    final pet = state;
    if (pet == null) return;
    pet.totalXp += amount;
    pet.lastUpdated = DateTime.now();
    await pet.save();
    state = _box.getAt(0);
  }

  Future<void> updateStreak(int streak) async {
    final pet = state;
    if (pet == null) return;
    pet.currentStreak = streak;
    if (streak > pet.longestStreak) pet.longestStreak = streak;
    pet.lastUpdated = DateTime.now();
    await pet.save();
    state = _box.getAt(0);
  }
}

final petProvider =
    NotifierProvider<PetNotifier, Pet?>(() => PetNotifier());

// Today's completion rate (0.0 - 1.0)
final completionRateProvider = Provider<double>((ref) {
  final habits = ref.watch(habitsProvider);
  final active  = habits.where((h) => h.isActive).toList();
  if (active.isEmpty) return 0.0;
  final done = active.where((h) => h.isCompletedToday).length;
  return done / active.length;
});
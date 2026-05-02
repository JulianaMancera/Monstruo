import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit_model.dart';
import '../../../core/constants/app_constants.dart';

const _uuid = Uuid();

class HabitsNotifier extends Notifier<List<Habit>> {
  @override
  List<Habit> build() {
    return _box.values.where((h) => h.isActive).toList();
  }

  Box<Habit> get _box => Hive.box<Habit>(AppConstants.habitsBox);

  Future<void> addHabit({
    required String title,
    required String category,
    String frequency = 'daily',
  }) async {
    final habit = Habit(
      id: _uuid.v4(),
      title: title,
      category: category,
      frequency: frequency,
      createdAt: DateTime.now(),
    );
    await _box.add(habit);
    _refresh();
  }

  Future<void> toggleCompletion(Habit habit) async {
    if (habit.isCompletedToday) {
      habit.uncompleteToday();
    } else {
      habit.completeToday();
    }
    _refresh();
  }

  Future<void> deleteHabit(Habit habit) async {
    habit.isActive = false;
    await habit.save();
    _refresh();
  }

  void _refresh() {
    state = _box.values.where((h) => h.isActive).toList();
  }
}

final habitsProvider =
    NotifierProvider<HabitsNotifier, List<Habit>>(() => HabitsNotifier());

// Grouped by category
final habitsByCategoryProvider = Provider<Map<String, List<Habit>>>((ref) {
  final habits = ref.watch(habitsProvider);
  return {
    for (final cat in AppConstants.categories)
      cat: habits.where((h) => h.category == cat).toList(),
  };
});
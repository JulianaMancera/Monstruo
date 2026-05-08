import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mood_model.dart';
import '../../../core/constants/app_constants.dart';

class MoodNotifier extends Notifier<List<MoodEntry>> {
  Box<MoodEntry> get _box => Hive.box<MoodEntry>(AppConstants.moodBox);

  @override
  List<MoodEntry> build() => _sorted();

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  MoodEntry? get todaysEntry {
    final today = _todayStr();
    try {
      return _box.values.firstWhere((e) => e.date == today);
    } catch (_) {
      return null;
    }
  }

  // Returns true when this is the first log of the day (so XP is awarded once).
  Future<bool> logMood(int score, {String? note}) async {
    final today = _todayStr();
    final isNew = todaysEntry == null;
    final existing = todaysEntry;
    if (existing != null) {
      existing.score = score;
      existing.note = note;
      await existing.save();
    } else {
      await _box.add(MoodEntry(date: today, score: score, note: note));
    }
    state = _sorted();
    return isNew;
  }

  List<MoodEntry> _sorted() =>
      _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
}

final moodProvider =
    NotifierProvider<MoodNotifier, List<MoodEntry>>(() => MoodNotifier());

final todaysMoodProvider = Provider<MoodEntry?>((ref) {
  final entries = ref.watch(moodProvider);
  final d = DateTime.now();
  final today =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  try {
    return entries.firstWhere((e) => e.date == today);
  } catch (_) {
    return null;
  }
});

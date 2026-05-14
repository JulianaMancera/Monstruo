import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/entry_model.dart';
import '../../../core/constants/app_constants.dart';

const _uuid = Uuid();

// ─── Entries Notifier ────────────────────────────────────────────

class EntriesNotifier extends Notifier<List<TimeEntry>> {
  Box<TimeEntry> get _box => Hive.box<TimeEntry>(AppConstants.entriesBox);

  @override
  List<TimeEntry> build() => _sorted();

  Future<void> addEntry({
    required String categoryId,
    required int durationMinutes,
    String? note,
  }) async {
    final now = DateTime.now();
    final entry = TimeEntry(
      id:              _uuid.v4(),
      categoryId:      categoryId,
      durationMinutes: durationMinutes,
      date:            _dateStr(now),
      note:            note,
      createdAt:       now,
    );
    await _box.add(entry);
    state = _sorted();
  }

  Future<void> deleteEntry(TimeEntry entry) async {
    await entry.delete();
    state = _sorted();
  }

  List<TimeEntry> _sorted() => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final entriesProvider =
    NotifierProvider<EntriesNotifier, List<TimeEntry>>(() => EntriesNotifier());

// ─── Derived Providers ───────────────────────────────────────────

String _todayStr() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final todayEntriesProvider = Provider<List<TimeEntry>>((ref) {
  final today = _todayStr();
  return ref.watch(entriesProvider).where((e) => e.date == today).toList();
});

final todayMinutesProvider = Provider<int>((ref) =>
    ref.watch(todayEntriesProvider).fold(0, (s, e) => s + e.durationMinutes));

final weekEntriesProvider = Provider<List<TimeEntry>>((ref) {
  final now       = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final cutoff    = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
  return ref.watch(entriesProvider).where((e) => e.date.compareTo(cutoff) >= 0).toList();
});

final weekMinutesByCategoryProvider = Provider<Map<String, int>>((ref) {
  final result = <String, int>{};
  for (final e in ref.watch(weekEntriesProvider)) {
    result[e.categoryId] = (result[e.categoryId] ?? 0) + e.durationMinutes;
  }
  return result;
});

final weekTotalMinutesProvider = Provider<int>((ref) =>
    ref.watch(weekMinutesByCategoryProvider).values.fold(0, (s, m) => s + m));

// Minutes per day Mon–Sun (index 0 = Monday)
final weekDailyMinutesProvider = Provider<List<int>>((ref) {
  final result    = List.filled(7, 0);
  final now       = DateTime.now();
  final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  for (final e in ref.watch(weekEntriesProvider)) {
    final parts = e.date.split('-');
    final date  = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final diff  = date.difference(weekStart).inDays;
    if (diff >= 0 && diff < 7) result[diff] += e.durationMinutes;
  }
  return result;
});

// ─── Timer State ─────────────────────────────────────────────────

class TimerState {
  final String? categoryId;
  final int elapsedSeconds;

  const TimerState({this.categoryId, this.elapsedSeconds = 0});

  bool get isRunning => categoryId != null;

  TimerState copyWith({String? categoryId, int? elapsedSeconds}) => TimerState(
    categoryId:     categoryId     ?? this.categoryId,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
  );
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _ticker;

  TimerNotifier() : super(const TimerState());

  void start(String categoryId) {
    _ticker?.cancel();
    state = TimerState(categoryId: categoryId, elapsedSeconds: 0);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  // Returns minutes elapsed (minimum 1 minute).
  int stop() {
    _ticker?.cancel();
    _ticker = null;
    final seconds = state.elapsedSeconds;
    state = const TimerState();
    return ((seconds / 60).ceil()).clamp(1, 9999);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerProvider =
    StateNotifierProvider<TimerNotifier, TimerState>((ref) => TimerNotifier());

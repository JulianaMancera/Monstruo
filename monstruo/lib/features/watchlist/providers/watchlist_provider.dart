import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/watchlist_model.dart';
import '../../../core/constants/app_constants.dart';

const _uuid = Uuid();

class WatchlistNotifier extends Notifier<List<WatchlistItem>> {
  Box<WatchlistItem> get _box =>
      Hive.box<WatchlistItem>(AppConstants.watchlistBox);

  @override
  List<WatchlistItem> build() => _sorted();

  Future<void> addItem({
    required String title,
    required String mediaType,
    String status = 'want',
  }) async {
    final item = WatchlistItem(
      id: _uuid.v4(),
      title: title,
      mediaType: mediaType,
      status: status,
      addedAt: DateTime.now(),
    );
    await _box.add(item);
    state = _sorted();
  }

  // Returns true when the item is newly marked completed (XP should be awarded).
  Future<bool> updateStatus(WatchlistItem item, String newStatus) async {
    final wasCompleted = item.status == 'completed';
    item.status = newStatus;
    await item.save();
    state = _sorted();
    return !wasCompleted && newStatus == 'completed';
  }

  Future<void> deleteItem(WatchlistItem item) async {
    await item.delete();
    state = _sorted();
  }

  List<WatchlistItem> _sorted() =>
      _box.values.toList()
        ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
}

final watchlistProvider =
    NotifierProvider<WatchlistNotifier, List<WatchlistItem>>(
        () => WatchlistNotifier());

final watchlistByStatusProvider =
    Provider<Map<String, List<WatchlistItem>>>((ref) {
  final items = ref.watch(watchlistProvider);
  return {
    'watching':  items.where((i) => i.status == 'watching').toList(),
    'want':      items.where((i) => i.status == 'want').toList(),
    'completed': items.where((i) => i.status == 'completed').toList(),
    'dropped':   items.where((i) => i.status == 'dropped').toList(),
  };
});

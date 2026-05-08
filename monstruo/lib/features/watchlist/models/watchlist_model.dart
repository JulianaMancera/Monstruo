import 'package:hive_flutter/hive_flutter.dart';

part 'watchlist_model.g.dart';

@HiveType(typeId: 3)
class WatchlistItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String mediaType; // show, anime, movie, book, game

  @HiveField(3)
  String status; // watching, want, completed, dropped

  @HiveField(4)
  DateTime addedAt;

  WatchlistItem({
    required this.id,
    required this.title,
    required this.mediaType,
    required this.status,
    required this.addedAt,
  });
}

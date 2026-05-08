import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/pet/models/pet_model.dart';
import 'features/habits/models/habit_model.dart';
import 'features/mood/models/mood_model.dart';
import 'features/watchlist/models/watchlist_model.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(PetAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(WatchlistItemAdapter());

  await Hive.openBox<Pet>(AppConstants.petBox);
  await Hive.openBox<Habit>(AppConstants.habitsBox);
  await Hive.openBox<MoodEntry>(AppConstants.moodBox);
  await Hive.openBox<WatchlistItem>(AppConstants.watchlistBox);

  runApp(
    const ProviderScope(
      child: MonstruoRoot(),
    ),
  );
}

class MonstruoRoot extends StatelessWidget {
  const MonstruoRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monstruo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MonstruoApp(),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/entries/models/entry_model.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TimeEntryAdapter());
  await Hive.openBox<TimeEntry>(AppConstants.entriesBox);

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

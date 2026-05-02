import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/pet/screens/pet_screen.dart';
import '../../features/habits/screens/habits_screen.dart';
import '../../features/dashboard/screens/stats_screen.dart';
import '../theme/app_theme.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MonstruoApp extends ConsumerWidget {
  const MonstruoApp({super.key});

  static const _screens = [
    PetScreen(),
    HabitsScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(index: currentTab, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.surfaceLight, width: 1)),
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: currentTab,
            onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon:       Text('🐾', style: TextStyle(fontSize: 22)),
                activeIcon: Text('🐾', style: TextStyle(fontSize: 26)),
                label: 'My Monstruo',
              ),
              BottomNavigationBarItem(
                icon:       Text('📋', style: TextStyle(fontSize: 22)),
                activeIcon: Text('📋', style: TextStyle(fontSize: 26)),
                label: 'Habits',
              ),
              BottomNavigationBarItem(
                icon:       Text('📊', style: TextStyle(fontSize: 22)),
                activeIcon: Text('📊', style: TextStyle(fontSize: 26)),
                label: 'Stats',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
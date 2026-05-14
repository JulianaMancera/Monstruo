import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../entries/providers/entry_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEntries       = ref.watch(entriesProvider);
    final weekMinutesByCat = ref.watch(weekMinutesByCategoryProvider);

    final totalMinutes = allEntries.fold(0, (s, e) => s + e.durationMinutes);
    final totalHours   = totalMinutes ~/ 60;
    final topCategory  = weekMinutesByCat.isEmpty
        ? null
        : weekMinutesByCat.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Your Stats', style: Theme.of(context).textTheme.bodyMedium),
            Text('Overview',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),

            const SizedBox(height: 24),

            // All-time hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF9C94FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('All Time',
                    style: TextStyle(
                      color: Colors.white70, fontSize: 13,
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('⏱', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${totalHours}h logged',
                            style: const TextStyle(
                              color: Colors.white, fontSize: 28,
                              fontWeight: FontWeight.w800)),
                          Text('across ${allEntries.length} sessions',
                            style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (topCategory != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Text(AppTheme.categoryIcons[topCategory] ?? '⏱',
                      style: const TextStyle(fontSize: 40)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Top this week',
                          style: Theme.of(context).textTheme.bodyMedium),
                        Text(
                          topCategory[0].toUpperCase() +
                              topCategory.substring(1),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 22)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Categories reference card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories',
                    style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: AppConstants.categories.map((cat) {
                      final color =
                          AppTheme.categoryColors[cat] ?? AppTheme.primary;
                      final icon =
                          AppTheme.categoryIcons[cat]  ?? '⏱';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(icon, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              cat[0].toUpperCase() + cat.substring(1),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

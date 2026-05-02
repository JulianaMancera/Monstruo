import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../pet/providers/pet_provider.dart';
import '../../habits/providers/habit_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet              = ref.watch(petProvider);
    final habits           = ref.watch(habitsProvider);
    final habitsByCategory = ref.watch(habitsByCategoryProvider);

    if (pet == null) {
      return const Scaffold(
        body: Center(child: Text('Hatch your Monstruo first! 🥚')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Progress', style: Theme.of(context).textTheme.bodyMedium),
            Text('Your Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26)),

            const SizedBox(height: 24),

            _XpCard(pet: pet),
            const SizedBox(height: 16),
            _CategoryCard(habitsByCategory: habitsByCategory),
            const SizedBox(height: 16),
            _WeeklyChart(habits: habits),
            const SizedBox(height: 16),
            _AllTimeCard(habits: habits, pet: pet),
          ],
        ),
      ),
    );
  }
}

// ─── XP Card ────────────────────────────────────────────────────

class _XpCard extends StatelessWidget {
  final dynamic pet;
  const _XpCard({required this.pet});

  @override
  Widget build(BuildContext context) {
    final stage    = pet.evolutionStage as Map<String, dynamic>;
    final progress = pet.evolutionProgress as double;
    final xpToNext = pet.xpToNextStage as int?;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${stage['emoji']} ${stage['name']}',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              Text('⚡ ${pet.totalXp} XP',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress, minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            xpToNext != null ? '$xpToNext XP until next evolution' : '🏆 Max evolution reached!',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── Category Breakdown ─────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final Map<String, List<dynamic>> habitsByCategory;
  const _CategoryCard({required this.habitsByCategory});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...AppConstants.categories.map((cat) {
            final habits    = habitsByCategory[cat] ?? [];
            if (habits.isEmpty) return const SizedBox.shrink();
            final completed = habits.where((h) => h.isCompletedToday).length;
            final color     = AppTheme.categoryColors[cat] ?? AppTheme.primary;
            final icon      = AppTheme.categoryIcons[cat]  ?? '📌';
            final progress  = habits.isEmpty ? 0.0 : completed / habits.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(icon),
                      const SizedBox(width: 8),
                      Text(cat[0].toUpperCase() + cat.substring(1),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text('$completed/${habits.length}',
                        style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress, minHeight: 8,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Weekly Bar Chart ────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final List<dynamic> habits;
  const _WeeklyChart({required this.habits});

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayWeekday = DateTime.now().weekday - 1;

    final bars = List.generate(7, (i) {
      final date    = DateTime.now().subtract(Duration(days: 6 - i));
      final dateStr = _dateStr(date);
      final done    = habits.where((h) => (h.completedDates as List).contains(dateStr)).length;
      final total   = habits.length;

      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: total == 0 ? 0 : done / total,
            color: AppTheme.primary,
            width: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true, toY: 1, color: AppTheme.surfaceLight),
          ),
        ],
      );
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 7 Days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              maxY: 1,
              barGroups: bars,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final dayIdx = (DateTime.now()
                        .subtract(Duration(days: 6 - value.toInt()))
                        .weekday - 1) % 7;
                      return Text(dayLabels[dayIdx],
                        style: TextStyle(
                          color: dayIdx == todayWeekday
                              ? AppTheme.primary : AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: dayIdx == todayWeekday
                              ? FontWeight.w700 : FontWeight.normal,
                        ));
                    },
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ─── All-Time Stats ──────────────────────────────────────────────

class _AllTimeCard extends StatelessWidget {
  final List<dynamic> habits;
  final dynamic pet;
  const _AllTimeCard({required this.habits, required this.pet});

  @override
  Widget build(BuildContext context) {
    final totalCompletions =
        habits.fold<int>(0, (sum, h) => sum + (h.totalCompletions as int));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All Time', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _BigStat(value: '${habits.length}',     label: 'Active\nHabits',   icon: '📋')),
              Expanded(child: _BigStat(value: '$totalCompletions',    label: 'Total\nDone',      icon: '✅')),
              Expanded(child: _BigStat(value: '${pet.longestStreak}', label: 'Best\nStreak',     icon: '🏆')),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value, label, icon;
  const _BigStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          textAlign: TextAlign.center),
      ],
    );
  }
}
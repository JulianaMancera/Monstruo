import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../entries/providers/entry_provider.dart';
import '../../../core/theme/app_theme.dart';

class WeeklyScreen extends ConsumerWidget {
  const WeeklyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalMinutes      = ref.watch(weekTotalMinutesProvider);
    final minutesByCategory = ref.watch(weekMinutesByCategoryProvider);
    final dailyMinutes      = ref.watch(weekDailyMinutesProvider);

    final now       = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd   = weekStart.add(const Duration(days: 6));
    final weekLabel =
        '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d').format(weekEnd)}';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('This Week', style: Theme.of(context).textTheme.bodyMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(weekLabel,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
                _TotalChip(minutes: totalMinutes),
              ],
            ),

            const SizedBox(height: 24),

            if (totalMinutes == 0)
              const _EmptyWeek()
            else ...[
              _PieCard(
                minutesByCategory: minutesByCategory,
                totalMinutes: totalMinutes),
              const SizedBox(height: 16),
              _BarCard(dailyMinutes: dailyMinutes),
              const SizedBox(height: 16),
              _CategoryList(
                minutesByCategory: minutesByCategory,
                totalMinutes: totalMinutes),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Total Chip ──────────────────────────────────────────────────

class _TotalChip extends StatelessWidget {
  final int minutes;
  const _TotalChip({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h     = minutes ~/ 60;
    final m     = minutes % 60;
    final label = h > 0 ? '${h}h ${m}m total' : '${m}m total';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.primary, fontWeight: FontWeight.w700)),
    );
  }
}

// ─── Pie Chart ───────────────────────────────────────────────────

class _PieCard extends StatelessWidget {
  final Map<String, int> minutesByCategory;
  final int totalMinutes;
  const _PieCard({required this.minutesByCategory, required this.totalMinutes});

  @override
  Widget build(BuildContext context) {
    final sections = minutesByCategory.entries.map((e) {
      final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
      final pct   = e.value / totalMinutes;
      return PieChartSectionData(
        color:     color,
        value:     e.value.toDouble(),
        title:     '${(pct * 100).toStringAsFixed(0)}%',
        radius:    70,
        titleStyle: const TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
        showTitle: pct >= 0.07,
      );
    }).toList();

    // Legend entries
    final legendItems = minutesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time Split', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: PieChart(PieChartData(
              sections:        sections,
              centerSpaceRadius: 40,
              sectionsSpace:   2,
            )),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10, runSpacing: 8,
            children: legendItems.map((e) {
              final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
              final icon  = AppTheme.categoryIcons[e.key]  ?? '⏱';
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 1.0), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('$icon ${e.key[0].toUpperCase()}${e.key.substring(1)}',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Bar Chart ───────────────────────────────────────────────────

class _BarCard extends StatelessWidget {
  final List<int> dailyMinutes;
  const _BarCard({required this.dailyMinutes});

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIdx  = DateTime.now().weekday - 1;
    final maxVal    = dailyMinutes.reduce((a, b) => a > b ? a : b).toDouble();
    final chartMax  = maxVal <= 0 ? 60.0 : (maxVal * 1.25).ceilToDouble();

    final bars = List.generate(7, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY:    dailyMinutes[i].toDouble(),
          color:  i == todayIdx
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.4),
          width:  24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true, toY: chartMax, color: AppTheme.surfaceLight),
        ),
      ],
    ));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Breakdown',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(BarChartData(
              maxY:      chartMax,
              barGroups: bars,
              gridData:  const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:   const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
                rightTitles:  const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
                topTitles:    const AxisTitles(
                  sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    return Text(dayLabels[i],
                      style: TextStyle(
                        color: i == todayIdx
                            ? AppTheme.primary : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: i == todayIdx
                            ? FontWeight.w700 : FontWeight.normal));
                  },
                )),
              ),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) {
                    final m   = rod.toY.toInt();
                    final h   = m ~/ 60;
                    final min = m % 60;
                    final lbl = h > 0 ? '${h}h ${min}m' : '${min}m';
                    return BarTooltipItem(lbl,
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12));
                  },
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}

// ─── Category List ───────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  final Map<String, int> minutesByCategory;
  final int totalMinutes;
  const _CategoryList({
    required this.minutesByCategory,
    required this.totalMinutes,
  });

  String _label(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final sorted = minutesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('By Category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ...sorted.map((e) {
            final color = AppTheme.categoryColors[e.key] ?? AppTheme.primary;
            final icon  = AppTheme.categoryIcons[e.key]  ?? '⏱';
            final pct   = e.value / totalMinutes;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        e.key[0].toUpperCase() + e.key.substring(1),
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(_label(e.value),
                        style: TextStyle(
                          color: color, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct, minHeight: 8,
                      backgroundColor: color.withValues(alpha: 0.15),
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

// ─── Empty Week ──────────────────────────────────────────────────

class _EmptyWeek extends StatelessWidget {
  const _EmptyWeek();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📊', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No data yet this week',
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Start logging your time to see\nhow your week is shaping up.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

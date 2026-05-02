import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../../pet/providers/pet_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsByCategory = ref.watch(habitsByCategoryProvider);
    final completionRate   = ref.watch(completionRateProvider);
    final hasAnyHabit      = habitsByCategory.values.any((l) => l.isNotEmpty);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Habits", style: Theme.of(context).textTheme.bodyMedium),
                      Text(_greeting(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22)),
                    ],
                  ),
                  _ProgressRing(progress: completionRate),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child: !hasAnyHabit
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: AppConstants.categories.map((cat) {
                        final habits = habitsByCategory[cat] ?? [];
                        if (habits.isEmpty) return const SizedBox.shrink();
                        return _CategorySection(category: cat, habits: habits);
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Habit',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning! ☀️';
    if (h < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _AddHabitSheet(ref: ref),
    );
  }
}

// ─── Category Section ───────────────────────────────────────────

class _CategorySection extends ConsumerWidget {
  final String category;
  final List<Habit> habits;

  const _CategorySection({required this.category, required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color     = AppTheme.categoryColors[category] ?? AppTheme.primary;
    final icon      = AppTheme.categoryIcons[category]  ?? '📌';
    final completed = habits.where((h) => h.isCompletedToday).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              category[0].toUpperCase() + category.substring(1),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
            ),
            const Spacer(),
            Text('$completed/${habits.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 10),
        ...habits.map((h) => _HabitCard(habit: h)),
      ],
    );
  }
}

// ─── Habit Card ─────────────────────────────────────────────────

class _HabitCard extends ConsumerWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color       = AppTheme.categoryColors[habit.category] ?? AppTheme.primary;
    final isCompleted = habit.isCompletedToday;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      onDismissed: (_) => ref.read(habitsProvider.notifier).deleteHabit(habit),
      child: GestureDetector(
        onTap: () async {
          final wasCompleted = habit.isCompletedToday;
          await ref.read(habitsProvider.notifier).toggleCompletion(habit);
          if (!wasCompleted) {
            await ref.read(petProvider.notifier).awardXp(AppConstants.xpPerHabit);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? color.withOpacity(0.15) : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? color.withOpacity(0.5) : AppTheme.surfaceLight),
          ),
          child: Row(
            children: [
              // Circle checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? color : Colors.transparent,
                  border: Border.all(
                    color: isCompleted ? color : AppTheme.textSecondary, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? AppTheme.textSecondary : AppTheme.textPrimary,
                      )),
                    if (habit.currentStreak > 0)
                      Text('🔥 ${habit.currentStreak} day streak',
                        style: const TextStyle(fontSize: 12, color: AppTheme.warning)),
                  ],
                ),
              ),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+${AppConstants.xpPerHabit} XP',
                    style: const TextStyle(
                      color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Progress Ring ──────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final double progress;
  const _ProgressRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56, height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 5,
            backgroundColor: AppTheme.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppTheme.success : AppTheme.primary),
          ),
          Text('${(progress * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

// ─── Empty State ────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🌱', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No habits yet!', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Add your first habit to start growing your Monstruo.',
            style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Add Habit Bottom Sheet ─────────────────────────────────────

class _AddHabitSheet extends StatefulWidget {
  final WidgetRef ref;
  const _AddHabitSheet({required this.ref});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _ctrl = TextEditingController();
  String _category  = 'health';
  String _frequency = 'daily';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Habit', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),

          TextField(
            controller: _ctrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'What habit do you want to build?'),
          ),
          const SizedBox(height: 16),

          Text('Category', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: AppConstants.categories.map((cat) {
              final isSelected = _category == cat;
              final color      = AppTheme.categoryColors[cat] ?? AppTheme.primary;
              return ChoiceChip(
                label: Text('${AppTheme.categoryIcons[cat]} ${cat[0].toUpperCase()}${cat.substring(1)}'),
                selected: isSelected,
                onSelected: (_) => setState(() => _category = cat),
                selectedColor: color.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: isSelected ? color : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                side: BorderSide(color: isSelected ? color : Colors.transparent),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text('Frequency', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['daily', 'weekdays', 'weekends'].map((freq) {
              final isSelected = _frequency == freq;
              return ChoiceChip(
                label: Text(freq[0].toUpperCase() + freq.substring(1)),
                selected: isSelected,
                onSelected: (_) => setState(() => _frequency = freq),
                selectedColor: AppTheme.primary.withOpacity(0.3),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
                side: BorderSide(color: isSelected ? AppTheme.primary : Colors.transparent),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Add Habit ✨'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final title = _ctrl.text.trim();
    if (title.isEmpty) return;
    widget.ref.read(habitsProvider.notifier).addHabit(
      title: title, category: _category, frequency: _frequency);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
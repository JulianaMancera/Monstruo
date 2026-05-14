import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/entry_provider.dart';
import '../models/entry_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayEntries = ref.watch(todayEntriesProvider);
    final todayMinutes = ref.watch(todayMinutesProvider);
    final timer        = ref.watch(timerProvider);
    final todayLabel   = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(todayLabel, style: Theme.of(context).textTheme.bodyMedium),
                      Text('Today',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontSize: 26, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  _TotalBadge(minutes: todayMinutes),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (timer.isRunning)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: _ActiveTimerCard(timer: timer),
              ),

            Expanded(
              child: todayEntries.isEmpty && !timer.isRunning
                  ? const _EmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: todayEntries
                          .map((e) => _EntryCard(entry: e))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogSheet(context, ref),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Time',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _LogSheet(ref: ref),
    );
  }
}

// ─── Total Badge ─────────────────────────────────────────────────

class _TotalBadge extends StatelessWidget {
  final int minutes;
  const _TotalBadge({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final h     = minutes ~/ 60;
    final m     = minutes % 60;
    final label = h > 0 ? '${h}h ${m}m' : '${m}m';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha:0.4)),
      ),
      child: Row(
        children: [
          const Text('⏱', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: AppTheme.primary)),
        ],
      ),
    );
  }
}

// ─── Active Timer Card ───────────────────────────────────────────

class _ActiveTimerCard extends ConsumerWidget {
  final TimerState timer;
  const _ActiveTimerCard({required this.timer});

  String _format(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catId = timer.categoryId!;
    final color = AppTheme.categoryColors[catId] ?? AppTheme.primary;
    final icon  = AppTheme.categoryIcons[catId]  ?? '⏱';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha:0.4)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(catId[0].toUpperCase() + catId.substring(1),
                  style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
                Text(_format(timer.elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final minutes = ref.read(timerProvider.notifier).stop();
              await ref.read(entriesProvider.notifier).addEntry(
                categoryId:      catId,
                durationMinutes: minutes,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha:0.5)),
              ),
              child: Text('Stop',
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Entry Card ──────────────────────────────────────────────────

class _EntryCard extends ConsumerWidget {
  final TimeEntry entry;
  const _EntryCard({required this.entry});

  String _durationLabel(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppTheme.categoryColors[entry.categoryId] ?? AppTheme.primary;
    final icon  = AppTheme.categoryIcons[entry.categoryId]  ?? '⏱';

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.danger.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.danger),
      ),
      onDismissed: (_) =>
          ref.read(entriesProvider.notifier).deleteEntry(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha:0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.categoryId[0].toUpperCase() +
                        entry.categoryId.substring(1),
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                  if (entry.note != null && entry.note!.isNotEmpty)
                    Text(entry.note!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_durationLabel(entry.durationMinutes),
                style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty State ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Nothing logged yet',
            style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Start a timer or log time manually\nto see how your day is going.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Log Sheet ───────────────────────────────────────────────────

class _LogSheet extends StatefulWidget {
  final WidgetRef ref;
  const _LogSheet({required this.ref});

  @override
  State<_LogSheet> createState() => _LogSheetState();
}

class _LogSheetState extends State<_LogSheet> {
  String _categoryId = 'work';
  int    _hours      = 0;
  int    _minutes    = 30;
  bool   _timerMode  = false;
  final  _noteCtrl   = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Time', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),

            // Mode toggle
            Row(
              children: [
                Expanded(child: _ModeButton(
                  label: '⏱ Timer',
                  selected: _timerMode,
                  onTap: () => setState(() => _timerMode = true))),
                const SizedBox(width: 10),
                Expanded(child: _ModeButton(
                  label: '✏️ Manual',
                  selected: !_timerMode,
                  onTap: () => setState(() => _timerMode = false))),
              ],
            ),
            const SizedBox(height: 20),

            // Category picker
            Text('Category', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final isSelected = _categoryId == cat;
                final color      = AppTheme.categoryColors[cat] ?? AppTheme.primary;
                final icon       = AppTheme.categoryIcons[cat]  ?? '⏱';
                return GestureDetector(
                  onTap: () => setState(() => _categoryId = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha:0.2)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent),
                    ),
                    child: Text(
                      '$icon ${cat[0].toUpperCase()}${cat.substring(1)}',
                      style: TextStyle(
                        color: isSelected ? color : AppTheme.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),

            if (!_timerMode) ...[
              const SizedBox(height: 20),
              Text('Duration', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DurationPicker(
                    label: 'Hours', value: _hours, max: 23,
                    onChanged: (v) => setState(() => _hours = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _DurationPicker(
                    label: 'Minutes', value: _minutes, max: 59,
                    onChanged: (v) => setState(() => _minutes = v))),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  hintText: 'Add a note (optional)'),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text(_timerMode ? 'Start Timer ▶' : 'Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_timerMode) {
      widget.ref.read(timerProvider.notifier).start(_categoryId);
      Navigator.pop(context);
    } else {
      final total = _hours * 60 + _minutes;
      if (total == 0) return;
      widget.ref.read(entriesProvider.notifier).addEntry(
        categoryId:      _categoryId,
        durationMinutes: total,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha:0.2)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.transparent),
        ),
        child: Text(label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  const _DurationPicker({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            _ArrowBtn(
              icon: Icons.remove,
              onTap: () { if (value > 0) onChanged(value - 1); }),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: Text('$value',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontSize: 22)))),
            const SizedBox(width: 8),
            _ArrowBtn(
              icon: Icons.add,
              onTap: () { if (value < max) onChanged(value + 1); }),
          ],
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textPrimary),
      ),
    );
  }
}

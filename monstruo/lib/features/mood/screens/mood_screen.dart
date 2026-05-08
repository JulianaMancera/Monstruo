import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';
import '../models/mood_model.dart';
import '../../pet/providers/pet_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int? _selectedScore;
  final _noteCtrl = TextEditingController();
  bool _prefilled = false;

  static const _moods = [
    {'score': 1, 'emoji': '😭', 'label': 'Rough'},
    {'score': 2, 'emoji': '😔', 'label': 'Low'},
    {'score': 3, 'emoji': '😐', 'label': 'Meh'},
    {'score': 4, 'emoji': '🙂', 'label': 'Good'},
    {'score': 5, 'emoji': '😄', 'label': 'Lit'},
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayEntry = ref.watch(todaysMoodProvider);
    final allEntries = ref.watch(moodProvider);

    // Pre-fill fields once when today's entry is found
    if (todayEntry != null && !_prefilled) {
      _prefilled = true;
      _selectedScore = todayEntry.score;
      _noteCtrl.text = todayEntry.note ?? '';
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Check In', style: Theme.of(context).textTheme.bodyMedium),
            Text('How are you feeling?',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 24)),
            const SizedBox(height: 28),

            _MoodSelector(
              selected: _selectedScore,
              moods: _moods,
              onSelect: (s) => setState(() => _selectedScore = s),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                hintText: 'Add a note... (optional)',
                prefixIcon:
                    Icon(Icons.edit_note, color: AppTheme.textSecondary),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedScore == null ? null : _logMood,
                child: Text(todayEntry == null ? 'Log Mood ✨' : 'Update Mood'),
              ),
            ),

            if (todayEntry != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '✅ Logged today — +${AppConstants.xpPerMoodLog} XP earned',
                  style: const TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],

            if (allEntries.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('Recent Moods',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...allEntries.take(7).map((e) => _MoodHistoryTile(entry: e)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _logMood() async {
    final score = _selectedScore!;
    final note =
        _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
    final isNew =
        await ref.read(moodProvider.notifier).logMood(score, note: note);
    if (isNew) {
      await ref
          .read(petProvider.notifier)
          .awardXp(AppConstants.xpPerMoodLog);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isNew
            ? 'Mood logged! +${AppConstants.xpPerMoodLog} XP ⚡'
            : 'Mood updated!'),
        backgroundColor: AppTheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }
}

// ─── Mood Selector ───────────────────────────────────────────────

class _MoodSelector extends StatelessWidget {
  final int? selected;
  final List<Map<String, dynamic>> moods;
  final void Function(int) onSelect;

  const _MoodSelector(
      {required this.selected,
      required this.moods,
      required this.onSelect});

  Color _color(int score) {
    switch (score) {
      case 1:
        return AppTheme.danger;
      case 2:
        return AppTheme.warning;
      case 3:
        return AppTheme.primary;
      case 4:
        return const Color(0xFF4DAEF0);
      case 5:
        return AppTheme.success;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: moods.map((m) {
        final score = m['score'] as int;
        final isSelected = selected == score;
        final color = _color(score);
        return GestureDetector(
          onTap: () => onSelect(score),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 72,
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : AppTheme.surfaceLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(m['emoji'] as String,
                    style:
                        TextStyle(fontSize: isSelected ? 28 : 22)),
                const SizedBox(height: 4),
                Text(m['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? color
                          : AppTheme.textSecondary,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── History Tile ────────────────────────────────────────────────

class _MoodHistoryTile extends StatelessWidget {
  final MoodEntry entry;
  const _MoodHistoryTile({required this.entry});

  static const _emojis = ['', '😭', '😔', '😐', '🙂', '😄'];
  static const _labels = ['', 'Rough', 'Low', 'Meh', 'Good', 'Lit'];

  Color _color(int score) {
    switch (score) {
      case 1:
        return AppTheme.danger;
      case 2:
        return AppTheme.warning;
      case 3:
        return AppTheme.primary;
      case 4:
        return const Color(0xFF4DAEF0);
      case 5:
        return AppTheme.success;
      default:
        return AppTheme.primary;
    }
  }

  String _formatDate(String d) {
    final p = d.split('-');
    if (p.length != 3) return d;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[int.parse(p[1])]} ${p[2]}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(entry.score);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(_emojis[entry.score],
              style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_labels[entry.score],
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: color)),
                if (entry.note != null && entry.note!.isNotEmpty)
                  Text(entry.note!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(_formatDate(entry.date),
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

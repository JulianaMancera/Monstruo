import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pet_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet            = ref.watch(petProvider);
    final completionRate = ref.watch(completionRateProvider);

    if (pet == null) return const _OnboardingView();

    final stage     = pet.evolutionStage;
    final mood      = pet.getMood(completionRate);
    final moodEmoji = pet.getMoodEmoji(completionRate);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Monstruo', style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 26, fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  _XpBadge(xp: pet.totalXp),
                ],
              ),

              const SizedBox(height: 32),

              // Pet display
              _PetDisplay(stage: stage, mood: mood, moodEmoji: moodEmoji),

              const SizedBox(height: 28),

              // Evolution card
              _EvolutionCard(pet: pet, stage: stage),

              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  Expanded(child: _StatCard(icon: '🔥', label: 'Streak',   value: '${pet.currentStreak}d',  color: AppTheme.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: '🏆', label: 'Best',     value: '${pet.longestStreak}d',  color: AppTheme.accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(icon: '✅', label: 'Today',    value: '${(completionRate * 100).toInt()}%', color: AppTheme.success)),
                ],
              ),

              const SizedBox(height: 16),

              // Mood card
              _MoodCard(mood: mood, moodEmoji: moodEmoji),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────

class _XpBadge extends StatelessWidget {
  final int xp;
  const _XpBadge({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text('$xp XP',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _PetDisplay extends StatelessWidget {
  final Map<String, dynamic> stage;
  final String mood;
  final String moodEmoji;

  const _PetDisplay({required this.stage, required this.mood, required this.moodEmoji});

  Color get _glowColor {
    switch (mood) {
      case 'happy':   return AppTheme.success;
      case 'neutral': return AppTheme.primary;
      case 'sad':     return AppTheme.warning;
      case 'sick':    return AppTheme.danger;
      default:        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200, height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          _glowColor.withOpacity(0.3),
          _glowColor.withOpacity(0.05),
          Colors.transparent,
        ]),
        boxShadow: [
          BoxShadow(color: _glowColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 10),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stage['emoji'] as String, style: const TextStyle(fontSize: 90)),
            Text(moodEmoji,                style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}

class _EvolutionCard extends StatelessWidget {
  final dynamic pet;
  final Map<String, dynamic> stage;

  const _EvolutionCard({required this.pet, required this.stage});

  @override
  Widget build(BuildContext context) {
    final xpToNext = pet.xpToNextStage as int?;
    final progress = pet.evolutionProgress as double;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stage['name'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryLight, fontWeight: FontWeight.w800)),
              Text(xpToNext != null ? '$xpToNext XP to evolve' : '✨ Max Stage!',
                style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppTheme.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(stage['description'] as String,
            style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          // Stage preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: AppConstants.evolutionStages.map((s) => Column(
              children: [
                Text(s['emoji'] as String, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 2),
                Text(s['name'] as String,
                  style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String mood, moodEmoji;

  const _MoodCard({required this.mood, required this.moodEmoji});

  String get _message {
    switch (mood) {
      case 'happy':   return "Your Monstruo is thriving! You're crushing it today! 🎉";
      case 'neutral': return "Your Monstruo is doing okay. Keep completing more habits!";
      case 'sad':     return "Your Monstruo is feeling down. It needs more from you today 💙";
      case 'sick':    return "Your Monstruo is sick! Complete habits to help it recover 🏥";
      default:        return '';
    }
  }

  Color get _color {
    switch (mood) {
      case 'happy':   return AppTheme.success;
      case 'neutral': return AppTheme.primary;
      case 'sad':     return AppTheme.warning;
      case 'sick':    return AppTheme.danger;
      default:        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(moodEmoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: _color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Onboarding (first launch) ──────────────────────────────────

class _OnboardingView extends ConsumerStatefulWidget {
  const _OnboardingView();

  @override
  ConsumerState<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<_OnboardingView> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🥚', style: TextStyle(fontSize: 100)),
              const SizedBox(height: 24),
              Text('Your egg is waiting!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
                textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Give your Monstruo a name to hatch it and begin your journey.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _ctrl,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(hintText: 'Enter a name...'),
                onSubmitted: (_) => _hatch(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hatch,
                  child: const Text('Hatch My Monstruo! 🐣'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _hatch() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    ref.read(petProvider.notifier).createPet(name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
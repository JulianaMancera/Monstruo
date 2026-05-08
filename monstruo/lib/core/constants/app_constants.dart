class AppConstants {
  // App name
  static const String appName = 'Monstruo';

  // Evolution stages
  static const List<Map<String, dynamic>> evolutionStages = [
    {
      'name': 'Hatchling',
      'minXp': 0,
      'emoji': '🥚',
      'description': 'Just hatched! Feed it with good habits.',
    },
    {
      'name': 'Sproutling',
      'minXp': 100,
      'emoji': '🐣',
      'description': 'Starting to grow! Keep up your habits.',
    },
    {
      'name': 'Growler',
      'minXp': 300,
      'emoji': '🐲',
      'description': 'Getting stronger! Your habits are paying off.',
    },
    {
      'name': 'Beastling',
      'minXp': 700,
      'emoji': '🦎',
      'description': 'A powerful creature! Consistency is your strength.',
    },
    {
      'name': 'Guardian',
      'minXp': 1500,
      'emoji': '🐉',
      'description': 'Legendary! You are a master of your habits.',
    },
  ];

  // XP rewards
  static const int xpPerHabit = 10;
  static const int xpStreakBonus = 5;
  static const int xpPerfectDayBonus = 20;

  // Mood thresholds (% of daily habits completed)
  static const double moodHappy = 0.8;
  static const double moodNeutral = 0.5;
  static const double moodSad = 0.2;

  // XP for new trackers
  static const int xpPerMoodLog        = 5;
  static const int xpWatchlistComplete = 15;

  // Hive box names
  static const String petBox       = 'pet_box';
  static const String habitsBox    = 'habits_box';
  static const String moodBox      = 'mood_box';
  static const String watchlistBox = 'watchlist_box';

  // Habit categories (Gen Z rename)
  static const List<String> categories = [
    'glow',   // health/wellness
    'brain',  // mind/learning
    'grind',  // work/study
    'vibe',   // social
    'feels',  // self-care
  ];
}
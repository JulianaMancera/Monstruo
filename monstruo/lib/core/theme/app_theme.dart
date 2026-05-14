import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFF6C63FF);
  static const Color primaryLight  = Color(0xFF9C94FF);
  static const Color secondary     = Color(0xFFFF6584);
  static const Color accent        = Color(0xFFFFD93D);
  static const Color success       = Color(0xFF6BCB77);
  static const Color warning       = Color(0xFFFF922B);
  static const Color danger        = Color(0xFFFF6B6B);
  static const Color background    = Color(0xFF0F0E17);
  static const Color surface       = Color(0xFF1A1A2E);
  static const Color surfaceLight  = Color(0xFF252540);
  static const Color textPrimary   = Color(0xFFF8F8FF);
  static const Color textSecondary = Color(0xFFAAAAAA);

  static const Map<String, Color> categoryColors = {
    'work':     Color(0xFFFFD93D),
    'learning': Color(0xFF4DAEF0),
    'rest':     Color(0xFF6BCB77),
    'social':   Color(0xFFFF6584),
    'health':   Color(0xFF6BFFB8),
    'creative': Color(0xFF9C94FF),
    'other':    Color(0xFFAAAAAA),
  };

  static const Map<String, String> categoryIcons = {
    'work':     '💼',
    'learning': '📚',
    'rest':     '😴',
    'social':   '💬',
    'health':   '💪',
    'creative': '🎨',
    'other':    '⚡',
  };

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          titleLarge:    TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
          titleMedium:   TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge:     TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium:    TextStyle(color: textSecondary, fontSize: 14),
          labelLarge:    TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C4DFF),
        secondary: Color(0xFF00E676),
        surface: Color(0xFF1E1E2E),
        error: Color(0xFFCF6679),
      ),
      scaffoldBackgroundColor: const Color(0xFF12121C),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ),
      useMaterial3: true,
    );
  }
}

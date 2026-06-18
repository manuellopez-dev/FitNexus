import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFFC8F135);
  static const backgroundColor = Color(0xFF0D0D0F);
  static const surfaceColor = Color(0xFF16161A);
  static const cardColor = Color(0xFF1E1E24);
  static const textPrimary = Color(0xFFE8E8F0);
  static const textMuted = Color(0xFF6B6B80);
  static const dangerColor = Color(0xFFFF4D6D);
  static const strokeColor = Color(0xFF2A2A35);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        error: dangerColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textMuted),
        ),
      ),
    );
  }
}
// FILE: lib/config/theme.dart
// OPIS: Definira boje, fontove i izgled aplikacije.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardSurface = Color(0xFF1E1E1E);
  static const Color textWhite = Color(0xFFEEEEEE);
  static const Color textGrey = Color(0xFFAAAAAA);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        secondary: primaryGold,
        surface: darkBackground,
        onPrimary: Colors.black,
        surfaceContainer: cardSurface,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryGold,
        ),
        bodyLarge: GoogleFonts.lato(fontSize: 16, color: textWhite),
        bodyMedium: GoogleFonts.lato(fontSize: 14, color: textGrey),
      ),
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

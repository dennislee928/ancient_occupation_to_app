import 'package:flutter/material.dart';

class AppTheme {
  static const canvas = Color(0xFFF4EBDD);
  static const card = Color(0xFFFFF8EE);
  static const cardSoft = Color(0xFFF1E3CF);
  static const ink = Color(0xFF21170F);
  static const muted = Color(0xFF6F6256);
  static const line = Color(0x1A21170F);
  static const accent = Color(0xFF9D5426);
  static const success = Color(0xFF2C7A63);
  static const warning = Color(0xFFC06A3B);
  static const danger = Color(0xFFA53D2D);

  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
      surface: card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          height: 1.0,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        headlineSmall: TextStyle(
          fontSize: 28,
          height: 1.1,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: muted,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
          color: muted,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: line),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardSoft,
        selectedColor: accent,
        disabledColor: cardSoft,
        side: const BorderSide(color: line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}

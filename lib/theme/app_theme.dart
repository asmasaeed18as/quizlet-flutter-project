import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF5F4BFF);
  static const Color secondary = Color(0xFF2AC5FF);
  static const Color accent = Color(0xFFFFB347);
  static const Color textPrimary = Color(0xFF17223B);
  static const Color surface = Color(0xFFF6F8FF);
  static const Color success = Color(0xFF2BB673);
  static const Color danger = Color(0xFFE74C3C);

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF3FF), Color(0xFFF9FCFF), Color(0xFFEFF8FF)],
  );

  static LinearGradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF101729), Color(0xFF18223A), Color(0xFF0D1322)],
      );
    }

    return screenGradient;
  }

  static ThemeData lightTheme() {
    return _theme(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ),
      brightness: Brightness.light,
    );
  }

  static ThemeData darkTheme() {
    return _theme(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0D1322),
      colorScheme: ColorScheme.fromSeed(
        seedColor: secondary,
        brightness: Brightness.dark,
        primary: secondary,
        secondary: accent,
      ),
      brightness: Brightness.dark,
    );
  }

  static ThemeData _theme({
    required bool useMaterial3,
    required Color scaffoldBackgroundColor,
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: useMaterial3,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      colorScheme: colorScheme,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: textPrimary),
        bodyMedium: TextStyle(color: Color(0xFF4A5568)),
      ).apply(
        bodyColor: isDark ? const Color(0xFFE8EEF8) : textPrimary,
        displayColor: isDark ? Colors.white : textPrimary,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF18223A) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E9F4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE4E9F4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF18223A) : Colors.white,
        elevation: 6,
        shadowColor: const Color(0x220B1B3F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

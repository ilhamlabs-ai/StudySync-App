import 'package:flutter/material.dart';

class AppTheme {
  static const Color accentPurple = Color(0xFF7C5CFF);
  static const double spacingXL = 32.0;
  static const double spacingXS = 4.0;
  static const double spacingXXL = 48.0;
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static BoxDecoration get panelDecoration => BoxDecoration(
    color: panelDark,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  // Colors matching your web app
  static const Color backgroundDark = Color(0xFF0F1724);
  static const Color accent = Color(0xFF7C5CFF);
  static const Color panelDark = Color(0xFF1A233A);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB0B8C1);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundDark, panelDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, backgroundDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Spacing
  static const double spacingL = 24.0;
  static const double spacingM = 16.0;
  static const double spacingS = 8.0;

  // Material 3 theme
  static ThemeData get materialTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      background: backgroundDark,
      primary: accent,
      secondary: panelDark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: textMuted),
    ),
  );
}

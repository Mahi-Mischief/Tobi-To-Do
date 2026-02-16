import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFF00B894);
  static const Color accent = Color(0xFFFF7675);

  // Light Theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2D3436);
  static const Color lightGray = Color(0xFFDFE6E9);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Dark Theme
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF505050);
  static const Color darkBorder = Color(0xFF404040);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFFBE76);
  static const Color error = Color(0xFFFF7675);
  static const Color info = Color(0xFF0984E3);

  // Gamification Colors
  static const Color gold = Color(0xFFFFD93D);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Pillar Colors
  static const Color plan = Color(0xFF6C5CE7);
  static const Color execute = Color(0xFF00B894);
  static const Color improve = Color(0xFFFF7675);
  static const Color become = Color(0xFFFFBE76);
  static const Color assist = Color(0xFF0984E3);
}

class AppTypography {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}

// Compatibility aliases used across the UI
class AppText {
  static const TextStyle heading2 = AppTypography.headlineMedium;
  static const TextStyle heading3 = AppTypography.headlineSmall;
  static const TextStyle heading1 = AppTypography.headlineLarge;
  static const TextStyle bodyMedium = AppTypography.bodyMedium;
  static const TextStyle bodySmall = AppTypography.bodySmall;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
}

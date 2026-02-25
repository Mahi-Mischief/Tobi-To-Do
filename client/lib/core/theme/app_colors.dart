import 'package:flutter/material.dart';

class AppColors {
  // Pastel core palette
  static const Color primary = Color(0xFF7C83FD); // soft indigo
  static const Color primaryLight = Color(0xFFEDE7F6); // pastel lavender
  static const Color primarySofter = Color(0xFFD1C4E9); // muted purple
  static const Color accentBlue = Color(0xFFD6E4FF); // soft blue wash
  static const Color accentPink = Color(0xFFFFE0EC); // muted pink
  static const Color accentPeach = Color(0xFFFFF2E5); // warm peach
  static const Color accentMint = Color(0xFFDFF7F2); // mint wash
  static const Color textPrimary = Color(0xFF2E2A4A); // deep slate
  static const Color textSecondary = Color(0xFF6B7280); // muted gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF7F8FF);
  static const Color background = Color(0xFFF6F7FB);
  static const Color border = Color(0xFFE6E8F5);

  // Status
  static const Color success = Color(0xFF7CD992);
  static const Color warning = Color(0xFFFFCF6F);
  static const Color error = Color(0xFFFF9AA2);
  static const Color info = Color(0xFF7AB8FF);

  // Pillar Colors (kept for compatibility with existing screens)
  static const Color plan = primary;
  static const Color execute = success;
  static const Color improve = warning;
  static const Color become = accentPink;
  static const Color assist = info;

  // Shadows
  static const Color shadowSoft = Color(0x1A000000); // 10% black

  // Gradient helpers
  static const List<Color> cardGradient = [primaryLight, primarySofter];
  static const List<Color> backgroundGradient = [primaryLight, accentBlue];
  static const List<Color> highlightGradient = [Color(0xFF8E8BE6), Color(0xFF9AC6F3)];
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
  static const double xxl = 40.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 16.0;
  static const double large = 24.0;
  static const double pill = 30.0;
}

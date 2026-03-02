import 'package:flutter/material.dart';

/// Centralized color tokens that must be used across the app.
/// All UI elements should reference these constants instead of ad-hoc values.
class AppColors {
  // Primary purples
  static const Color primaryMedium = Color(0xFFD0D5FE);
  static const Color primaryDark = Color(0xFFA4A9F5);
  static const Color primaryLight = Color(0xFFF2F0FE); // background

  // Actions
  static const Color primaryButtonBlue = Color(0xFF89A9FE);

  // Pastels / accents
  static const Color cardBackground = Color(0xFFF9F3FE);
  static const Color cardOutline = Color(0xFFFBE6F2);
  static const Color pastelPinkMedium = Color(0xFFEEBCD8);
  static const Color pastelPinkLight = Color(0xFFFCD9EB);
  static const Color pastelYellowMedium = Color(0xFFFDE5CA);
  static const Color pastelYellowLight = Color(0xFFFDF2D6);
  static const Color pastelGreen = Color(0xFFAFD1CA);

  // Star gradients
  static const Color starLight = Color(0xFFFFF3C9);
  static const Color starDark = Color(0xFFF0D2B2);

  // Text
  static const Color textPrimary = Color(0xFF4B4B6A);
  static const Color textSecondary = Color(0xFF6F6F9E);

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x66FFFFFF);

  // Shadows (soft, never pure black)
  static const Color shadowSoft = Color(0x262E2E2E); // 15% charcoal

  // Gradient helpers
  static const LinearGradient defaultBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primaryLight],
  );

  static const LinearGradient focusBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9DA2EF), Color(0xFFC7CCFF)],
  );

  static const RadialGradient dreamBackgroundGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [pastelPinkLight, pastelYellowLight, primaryLight],
    stops: [0.0, 0.65, 1.0],
  );

  static const LinearGradient starGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [starLight, starDark],
  );
}

class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.6);
  static const TextStyle headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.2);
  static const TextStyle headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const TextStyle titleLarge = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle titleSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle labelLarge = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2);
  static const TextStyle labelMedium = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.2);
  static const TextStyle labelSmall = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.2);
}

// Compatibility aliases for older code paths
class AppText {
  static const TextStyle heading1 = AppTextStyles.headlineLarge;
  static const TextStyle heading2 = AppTextStyles.headlineMedium;
  static const TextStyle heading3 = AppTextStyles.headlineSmall;
  static const TextStyle bodyMedium = AppTextStyles.bodyMedium;
  static const TextStyle bodySmall = AppTextStyles.bodySmall;
}

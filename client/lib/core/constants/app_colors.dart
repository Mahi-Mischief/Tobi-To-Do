import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Pastel tones)
  static const Color primary = Color(0xFFB19CD9); // Soft purple
  static const Color secondary = Color(0xFFA8D8EA); // Soft blue
  static const Color tertiary = Color(0xFFFFB7B2); // Soft coral

  // Accent Colors
  static const Color success = Color(0xFFA8E6CF); // Soft green
  static const Color warning = Color(0xFFFFD3B6); // Soft orange
  static const Color error = Color(0xFFFF9999); // Soft red
  
  // Grayscale (Light Mode)
  static const Color darkText = Color(0xFF2C3E50);
  static const Color lightText = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF7F8C8D);
  static const Color lightGray = Color(0xFFF0F0F0);
  static const Color darkGray = Color(0xFF34495E);

  // Background Colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color darkBackground = Color(0xFF1A1A1A);

  // Priority colors
  static const Color highPriority = Color(0xFFFF9999);
  static const Color mediumPriority = Color(0xFFFFD3B6);
  static const Color lowPriority = Color(0xFFA8E6CF);

  // Status colors
  static const Color completed = Color(0xFFA8E6CF);
  static const Color inProgress = Color(0xFFA8D8EA);
  static const Color todo = Color(0xFFF0F0F0);
}

class AppTypography {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.darkText,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mediumGray,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.mediumGray,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 24.0;
}

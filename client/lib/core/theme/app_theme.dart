import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'radius.dart';
import 'spacing.dart';

// Re-export tokens so callers can import only `app_theme.dart`.
export 'app_colors.dart';
export 'spacing.dart';
export 'radius.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryMedium,
      scaffoldBackgroundColor: AppColors.primaryLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryMedium,
        secondary: AppColors.primaryButtonBlue,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        background: AppColors.primaryLight,
      ),
      textTheme: baseText.copyWith(
        headlineLarge: baseText.headlineLarge?.merge(AppTextStyles.headlineLarge).copyWith(color: AppColors.textPrimary),
        headlineMedium: baseText.headlineMedium?.merge(AppTextStyles.headlineMedium).copyWith(color: AppColors.textPrimary),
        headlineSmall: baseText.headlineSmall?.merge(AppTextStyles.headlineSmall).copyWith(color: AppColors.textPrimary),
        titleLarge: baseText.titleLarge?.merge(AppTextStyles.titleLarge).copyWith(color: AppColors.textPrimary),
        titleMedium: baseText.titleMedium?.merge(AppTextStyles.titleMedium).copyWith(color: AppColors.textPrimary),
        titleSmall: baseText.titleSmall?.merge(AppTextStyles.titleSmall).copyWith(color: AppColors.textPrimary),
        bodyLarge: baseText.bodyLarge?.merge(AppTextStyles.bodyLarge).copyWith(color: AppColors.textPrimary),
        bodyMedium: baseText.bodyMedium?.merge(AppTextStyles.bodyMedium).copyWith(color: AppColors.textSecondary),
        bodySmall: baseText.bodySmall?.merge(AppTextStyles.bodySmall).copyWith(color: AppColors.textSecondary),
        labelLarge: baseText.labelLarge?.merge(AppTextStyles.labelLarge).copyWith(color: AppColors.textPrimary),
        labelMedium: baseText.labelMedium?.merge(AppTextStyles.labelMedium).copyWith(color: AppColors.textSecondary),
        labelSmall: baseText.labelSmall?.merge(AppTextStyles.labelSmall).copyWith(color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: baseText.titleLarge?.merge(AppTextStyles.titleLarge).copyWith(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryMedium,
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          side: const BorderSide(color: AppColors.cardOutline, width: 1),
        ),
        elevation: 6,
        shadowColor: AppColors.shadowSoft,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primaryLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.cardOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.cardOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
          borderSide: const BorderSide(color: AppColors.primaryMedium, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryButtonBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMedium,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        ),
      ),
      dividerColor: AppColors.cardOutline,
    );
  }

  static ThemeData get darkTheme {
    // Pastel theme is primary; dark is minimal for compatibility.
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: AppColors.primaryMedium,
      colorScheme: const ColorScheme.dark(primary: AppColors.primaryMedium),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: AppColors.primaryMedium,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  // Backward-compat getters
  static Color get primaryColor => AppColors.primaryMedium;
  static Color get successColor => AppColors.pastelGreen;
  static Color get warningColor => AppColors.pastelYellowMedium;
}


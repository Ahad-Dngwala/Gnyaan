import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg800,
      canvasColor: AppColors.bg800,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.bg600,
        onSurface: AppColors.text,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.border300,
      ),

      // ── Typography ──────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL,
        displayMedium: AppTextStyles.displayLg,
        displaySmall: AppTextStyles.displayMd,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),

      // ── AppBar ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.h2,
        iconTheme: const IconThemeData(color: AppColors.icon),
      ),

      // ── Bottom Navigation ────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bg800,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.iconSubtle,
        elevation: 0,
      ),

      // ── Cards ────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.bg600,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border200),
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bg700,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textPlaceholder),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bg600,
        selectedColor: AppColors.brandGlow,
        labelStyle: AppTextStyles.labelMd,
        side: const BorderSide(color: AppColors.border300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border200,
        thickness: 1,
        space: 0,
      ),

      // ── Floating Action Button ────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // ── Progress ─────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand,
        linearTrackColor: AppColors.bg500,
      ),
    );
  }
}

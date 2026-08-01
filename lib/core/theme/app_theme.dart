import 'package:flutter/material.dart';

/// Paleta de cores da aplicação — identidade "fast food" (grelha + chama).
class AppColors {
  AppColors._();

  static const Color flame = Color(0xFFE63E2E);
  static const Color mustard = Color(0xFFF4A926);
  static const Color charcoal = Color(0xFF2B1F1A);
  static const Color cream = Color(0xFFFFF9F2);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.flame,
        primary: AppColors.flame,
        secondary: AppColors.mustard,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.flame,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: AppColors.charcoal,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.charcoal,
        ),
        bodyLarge: TextStyle(color: AppColors.charcoal),
        bodyMedium: TextStyle(color: AppColors.charcoal),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.flame,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

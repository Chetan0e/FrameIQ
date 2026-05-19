import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.accent,
          secondary: AppColors.accent3,
          error: AppColors.accent2,
        ),
        fontFamily: 'SF Pro Display', // fallback to system
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
          ),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textMuted),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      );
}

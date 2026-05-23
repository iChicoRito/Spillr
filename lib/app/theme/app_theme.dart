import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal500,
        primary: AppColors.teal500,
        surface: Colors.white,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: const TextStyle(
          fontSize: 48,
          height: 1.08,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
        headlineSmall: const TextStyle(
          fontSize: 24,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
        bodyLarge: const TextStyle(
          fontSize: 18,
          height: 1.33,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral400,
        ),
        bodyMedium: const TextStyle(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.neutral300,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.red500, width: 1.5),
        ),
      ),
    );
  }
}

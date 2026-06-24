import 'package:flutter/material.dart';
import 'package:our_today/core/theme/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: const TextTheme().apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}

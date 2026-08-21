import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Unified dark theme built from design tokens.
///
/// Chamfered corners: 8px (elements), 16px (large containers).
/// Taken from Beyblade piece geometry.
abstract final class AppTheme {
  static const double cornerRadius = 8;
  static const double cornerRadiusLg = 16;

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.void_,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.void_,
        primary: AppColors.x,
        secondary: AppColors.dragoon,
        error: AppColors.dranzer,
        onSurface: AppColors.text,
        onPrimary: AppColors.void_,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.text,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.text,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.text,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.text),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.text),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.mute),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.steel,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
    );
  }
}

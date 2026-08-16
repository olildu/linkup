import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linkup/shared_ui/constants/colors.dart';
import 'package:linkup/shared_ui/theme/app_typography.dart';
import 'package:linkup/shared_ui/theme/app_radius.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    final inTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (inTest) return base;
    return AppTypography.textThemeFromBase(base);
  }

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.whiteText,
    secondary: AppColors.primary,
    onSecondary: AppColors.whiteText,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    onError: AppColors.whiteText,
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF111111),
    surfaceContainerLow: Color(0xFFF5F5F5),
    surfaceContainerHighest: Color(0xFFD7D7D7),
    outline: Color(0xFFE6E6E6),
  );

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.whiteText,
    secondary: AppColors.primary,
    onSecondary: AppColors.whiteText,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    onError: AppColors.whiteText,
    surface: Color(0xFF111111),
    onSurface: Color(0xFFF5F5F5),
    surfaceContainerLow: Color(0xFF1F1D1D),
    surfaceContainerHighest: Color(0xFF2A2A2A),
    outline: Color(0xFF171717),
  );

  static ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = brightness == Brightness.light
        ? _lightColorScheme
        : _darkColorScheme;
    final textTheme = _buildTextTheme(brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      cardColor: colorScheme.surfaceContainerLow,
      appBarTheme: AppBarTheme(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.whiteText,
          textStyle: textTheme.labelLarge,
          minimumSize: const Size(double.infinity, 52),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.hint),
        labelStyle: textTheme.bodyMedium,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
      ),
    );
  }
}

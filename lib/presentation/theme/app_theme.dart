import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/theme/app_typography.dart';
import 'package:linkup/presentation/theme/app_radius.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme;
    final inTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (inTest) return base;
    return AppTypography.textThemeFromBase(base);
  }

  static ColorScheme _lightColorScheme() => const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.whiteTextColor,
    secondary: AppColors.primary,
    onSecondary: AppColors.whiteTextColor,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightText,
    error: AppColors.error,
    onError: AppColors.whiteTextColor,
    outline: Color.fromARGB(255, 230, 230, 230),
  ).copyWith(background: AppColors.lightBackground);

  static ColorScheme _darkColorScheme() => const ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: AppColors.whiteTextColor,
    secondary: AppColors.primary,
    onSecondary: AppColors.whiteTextColor,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkText,
    error: AppColors.error,
    onError: AppColors.whiteTextColor,
    outline: Color.fromARGB(255, 23, 23, 23),
  ).copyWith(background: AppColors.darkBackground);

  static ThemeData lightTheme = _buildTheme(Brightness.light);

  static ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = brightness == Brightness.light ? _lightColorScheme() : _darkColorScheme();
    final textTheme = _buildTextTheme(brightness);

    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme,
      cardColor: colorScheme.surface,
      appBarTheme: AppBarTheme(foregroundColor: colorScheme.onSurface, backgroundColor: colorScheme.surface, elevation: 0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: textTheme.labelLarge)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        color: colorScheme.surface,
        elevation: 0,
      ),
    );
  }
}

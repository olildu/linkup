// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// Backwards-compat export: some test files import this file and expect `AppTheme`.
export 'package:linkup/presentation/theme/app_theme.dart';

class AppColors {
  static const Color lightBackground = Colors.white;
  static const Color lightText = Colors.black;

  static const Color darkBackground = Colors.black;
  static const Color darkText = Colors.white;

  static const Color notSelected = Color.fromARGB(255, 99, 99, 99);
  static const Color whiteTextColor = Colors.white;
  static const Color whiteGreyTextColor = Color.fromARGB(255, 180, 180, 180);
  static const Color primary = Color(0xFF00B3B3);

  static const Color error = Color(0xFFF41505);
  static const Color success = Color(0xFF2E7D32);
  static const Color hint = Color(0xFFBFBFBF);
  static const Color subtitleLight = Color.fromARGB(255, 175, 175, 175);
  static const Color link = primary;

  static const Color authScaffoldBackground = Color(0xFFFAFAFA);
  static const Color tabBarTrack = Color(0xFFE0E0E0);
}

/// Semantic text-style helpers built from [ThemeData].
class AppTextStyles {
  AppTextStyles._();

  static TextStyle? body(BuildContext context) => Theme.of(context).textTheme.bodyMedium;

  static TextStyle? title(BuildContext context) => Theme.of(context).textTheme.titleLarge;

  static TextStyle? subtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 200, 200, 200)
            : AppColors.subtitleLight,
      );

  static TextStyle? label(BuildContext context) => Theme.of(context).textTheme.labelLarge?.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
    fontWeight: FontWeight.w500,
  );

  static TextStyle? hint(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint);

  static TextStyle? error(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error);

  static TextStyle? link(BuildContext context) => Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: Theme.of(context).colorScheme.primary,
    fontWeight: FontWeight.w500,
  );

  static TextStyle? destructive(BuildContext context) => Theme.of(context).textTheme.bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500);

  static TextStyle? onPrimary(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary);
}

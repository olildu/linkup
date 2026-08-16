import 'package:flutter/material.dart';
// Backwards-compat export: some test files import this file and expect `AppTheme`.
export 'package:linkup/shared_ui/theme/app_theme.dart';

/// Raw palette — hex values live here and nowhere else.
/// Do not reference these directly in UI code. Use [AppColors] instead.
abstract final class _Palette {
  static const teal400 = Color(0xFF00B3B3);
  static const red600 = Color(0xFFF41505);
  static const red50 = Color(0x1AFF0000); // red at 10% alpha
  static const green800 = Color(0xFF2E7D32);
  static const grey200 = Color(0xFFE0E0E0);
  static const grey300 = Color(0xFFBFBFBF);
  static const grey400 = Color(0xFFB4B4B4);
  static const grey500 = Color(0xFFAFAFAF);
  static const grey600 = Color(0xFF636363);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

/// Semantic color tokens — use these in all UI code.
///
/// For colors that adapt between light and dark mode, use
/// [Theme.of(context).colorScheme] — those are defined in [AppTheme].
abstract final class AppColors {
  // Brand
  static const primary = _Palette.teal400;

  // States
  static const error = _Palette.red600;
  static const errorContainer = _Palette.red50;
  static const success = _Palette.green800;

  // Text / interactive
  static const hint = _Palette.grey300;
  static const notSelected = _Palette.grey600;
  static const subtitleLight = _Palette.grey500;
  static const whiteGreyTextColor = _Palette.grey400;
  static const whiteText = _Palette.white;

  // Surfaces (theme-agnostic)
  static const tabBarTrack = _Palette.grey200;

  // Overlay / full-screen (always dark regardless of theme)
  static const scrim = _Palette.black;
  static const onScrim = _Palette.white;
}

/// Semantic text-style helpers built from [ThemeData].
class AppTextStyles {
  AppTextStyles._();

  static TextStyle? body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium;

  static TextStyle? title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge;

  static TextStyle? subtitle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      );

  static TextStyle? label(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      );

  static TextStyle? hint(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.hint);

  static TextStyle? error(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error);

  static TextStyle? link(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w500,
      );

  static TextStyle? destructive(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w500,
      );

  static TextStyle? onPrimary(BuildContext context) => Theme.of(context)
      .textTheme
      .bodyMedium
      ?.copyWith(color: Theme.of(context).colorScheme.onPrimary);
}

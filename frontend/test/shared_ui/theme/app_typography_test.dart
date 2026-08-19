import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/theme/app_typography.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('textThemeFromBase applies sizes and weights to every role', () {
    final theme = AppTypography.textThemeFromBase(Typography.blackMountainView);

    expect(theme.displayLarge!.fontSize, 42);
    expect(theme.displayLarge!.fontWeight, FontWeight.w700);
    expect(theme.displayMedium!.fontSize, 30);
    expect(theme.displaySmall!.fontSize, 26);
    expect(theme.headlineLarge!.fontSize, 24);
    expect(theme.headlineMedium, isNotNull);
    expect(theme.headlineSmall, isNotNull);
    expect(theme.titleLarge, isNotNull);
    expect(theme.titleMedium, isNotNull);
    expect(theme.titleSmall, isNotNull);
    expect(theme.bodyLarge, isNotNull);
    expect(theme.bodyMedium, isNotNull);
    expect(theme.bodySmall, isNotNull);
    expect(theme.labelLarge, isNotNull);
    expect(theme.labelMedium, isNotNull);
    expect(theme.labelSmall, isNotNull);
  });
}

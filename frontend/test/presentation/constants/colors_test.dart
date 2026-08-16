import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/constants/colors.dart';

void main() {
  group('AppTheme Coverage', () {

    test('lightTheme initialization covers all lines', () {
      final theme = AppTheme.lightTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.colorScheme.onPrimary, AppColors.whiteText);
    });

    test('darkTheme initialization covers all lines', () {
      final theme = AppTheme.darkTheme;

      expect(theme, isA<ThemeData>());
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.error, AppColors.error);
    });
  });
}

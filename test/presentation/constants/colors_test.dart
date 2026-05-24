import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/constants/colors.dart';

void main() {
  group('AppTheme Coverage', () {
    
    // Test Case 1: Ensures AppTheme.lightTheme is correctly initialized
    test('lightTheme initialization covers all lines', () {
      // 1. Arrange (Expected Values)
      const expectedBrightness = Brightness.light;
      const expectedBackground = AppColors.lightBackground;

      // 2. Act: Access the static getter to force initialization
      final theme = AppTheme.lightTheme; // This executes lines 19, 22, 28, 31, 37

      // 3. Assert: Verify the object is correctly instantiated and configured
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, expectedBrightness);
      expect(theme.scaffoldBackgroundColor, expectedBackground);
      expect(theme.appBarTheme.foregroundColor, AppColors.lightText);
      expect(theme.colorScheme.background, expectedBackground); // Check ColorScheme coverage
      expect(theme.colorScheme.onPrimary, AppColors.whiteTextColor);
      expect(theme.colorScheme.error, AppColors.error);
      expect(theme.colorScheme.primary, AppColors.primary);
    });

    // Test Case 2: Ensures AppTheme.darkTheme is correctly initialized
    test('darkTheme initialization covers all lines', () {
      // 1. Arrange (Expected Values)
      const expectedBrightness = Brightness.dark;
      const expectedBackground = AppColors.darkBackground;

      // 2. Act: Access the static getter to force initialization
      final theme = AppTheme.darkTheme; // This executes lines 42, 45, 51, 57, 60

      // 3. Assert: Verify the object is correctly instantiated and configured
      expect(theme, isA<ThemeData>());
      expect(theme.brightness, expectedBrightness);
      expect(theme.scaffoldBackgroundColor, expectedBackground);
      expect(theme.appBarTheme.foregroundColor, AppColors.darkText); // Check AppBarTheme coverage
      expect(theme.colorScheme.background, expectedBackground); // Check ColorScheme coverage
      expect(theme.colorScheme.error, AppColors.error);
    });
  });
}
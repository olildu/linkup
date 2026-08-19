import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/theme/app_media_ratios.dart';
import 'package:linkup/shared_ui/theme/app_radius.dart';
import 'package:linkup/shared_ui/theme/app_shadows.dart';
import 'package:linkup/shared_ui/theme/theme_extensions.dart';

import '../../helpers/test_helper.dart';

void main() {
  test('radius scale is ordered and shadows define blur', () {
    expect(AppRadius.sm, lessThan(AppRadius.md));
    expect(AppRadius.md, lessThan(AppRadius.lg));
    expect(AppRadius.lg, lessThan(AppRadius.xl));
    expect(AppRadius.full, 999.0);

    expect(AppShadows.card.single.blurRadius, 8);
    expect(AppShadows.elevated.single.blurRadius, 16);
    expect(AppMediaRatios.candidatePhoto, closeTo(9 / 16, 0.001));
  });

  testWidgets('ThemeX exposes colors and textTheme from the context',
      (tester) async {
    late ColorScheme colors;
    late TextTheme textTheme;
    await tester.pumpWidget(buildTestWidget(Builder(builder: (context) {
      colors = context.colors;
      textTheme = context.textTheme;
      return const SizedBox();
    })));
    expect(colors, Theme.of(tester.element(find.byType(SizedBox))).colorScheme);
    expect(textTheme, isNotNull);
  });
}

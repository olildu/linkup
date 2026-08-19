import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';

import '../../helpers/test_helper.dart';

void main() {
  test('token scale is ordered ascending', () {
    final scale = [
      AppSpacing.xxs,
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xl2,
      AppSpacing.xl3,
      AppSpacing.xl4,
      AppSpacing.xl5,
    ];
    for (var i = 1; i < scale.length; i++) {
      expect(scale[i], greaterThan(scale[i - 1]));
    }
  });

  testWidgets('responsive screen paddings resolve under ScreenUtil',
      (tester) async {
    late double h, v;
    await tester.pumpWidget(buildTestWidget(Builder(builder: (context) {
      h = AppSpacing.screenH;
      v = AppSpacing.screenV;
      return const SizedBox();
    })));
    expect(h, greaterThan(0));
    expect(v, greaterThan(0));
  });
}

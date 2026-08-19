import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/lobby/presentation/components/background_animation.dart';
import 'package:linkup/shared_ui/utils/bezier_design.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  testWidgets('paints the animated waves and shows the child', (tester) async {
    await tester.pumpWidget(buildTestWidget(BackgroundAnimation(
      animation: const AlwaysStoppedAnimation(0.25),
      child: const Center(child: Text('lobby')),
    )));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('lobby'), findsOneWidget);
    final paint = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    expect(paint.any((p) => p.painter is RPSCustomPainter), isTrue);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('blur mode adds a BackdropFilter once the tween runs',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(BackgroundAnimation(
      animation: const AlwaysStoppedAnimation(0.5),
      blur: true,
    )));
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  test('RPSCustomPainter always repaints', () {
    expect(RPSCustomPainter(0).shouldRepaint(RPSCustomPainter(1)), isTrue);
  });
}

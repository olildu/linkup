import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/utils/logo_design.dart';

import '../../helpers/test_helper.dart';

void main() {
  Future<void> paintAt(WidgetTester tester, double progress) async {
    await tester.pumpWidget(buildTestWidget(CustomPaint(
      size: const Size(220, 90),
      painter: DrawingPainter(AlwaysStoppedAnimation(progress), Colors.teal),
    )));
    await tester.pump();
  }

  testWidgets('paints across the stroke and fill phases without errors',
      (tester) async {
    await paintAt(tester, 0.0); // transparent stroke branch
    await paintAt(tester, 0.2); // colored stroke, no fill
    await paintAt(tester, 0.7); // stroke + partial fill
    await paintAt(tester, 1.0); // fully drawn
    expect(tester.takeException(), isNull);
  });

  test('repaints only when progress changes', () {
    const a = AlwaysStoppedAnimation(0.2);
    const b = AlwaysStoppedAnimation(0.8);
    expect(DrawingPainter(a, Colors.teal)
        .shouldRepaint(DrawingPainter(b, Colors.teal)), isTrue);
    expect(DrawingPainter(a, Colors.teal)
        .shouldRepaint(DrawingPainter(a, Colors.teal)), isFalse);
  });
}

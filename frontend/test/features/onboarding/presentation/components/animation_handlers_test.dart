import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/onboarding/presentation/components/animation_handlers.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  testWidgets('PageTransitionSwitcher animates between children',
      (tester) async {
    Widget page(String label) => PageTransitionSwitcher(
          duration: const Duration(milliseconds: 100),
          transitionBuilder: (child, animation) => SharedAxisTransition(
            animation: animation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          child: Text(label, key: ValueKey(label)),
        );

    await tester.pumpWidget(buildTestWidget(page('one')));
    expect(find.text('one'), findsOneWidget);

    await tester.pumpWidget(buildTestWidget(page('two')));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('two'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('one'), findsNothing);
  });

  testWidgets('all SharedAxisTransition variants build', (tester) async {
    for (final type in SharedAxisTransitionType.values) {
      await tester.pumpWidget(buildTestWidget(SharedAxisTransition(
        animation: const AlwaysStoppedAnimation(0.5),
        transitionType: type,
        child: Text('t-$type'),
      )));
      expect(find.text('t-$type'), findsOneWidget);
    }
  });
}

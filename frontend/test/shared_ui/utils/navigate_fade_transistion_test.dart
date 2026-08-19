import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/utils/navigate_fade_transistion.dart';

import '../../helpers/test_helper.dart';

void main() {
  testWidgets('navigateWithFade pushes the page with a fade and keeps history',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () =>
            navigateWithFade(context, const Text('destination')),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('destination'), findsOneWidget);
    await tester.pumpAndSettle();

    // History kept: back pops to the original page.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('allowBack: false clears the previous routes', (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => navigateWithFade(
            context, const Text('destination'),
            allowBack: false),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('destination'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    expect(navigator.canPop(), isFalse);
  });
}

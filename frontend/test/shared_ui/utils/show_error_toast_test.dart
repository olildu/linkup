import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/utils/show_error_toast.dart';

import '../../helpers/test_helper.dart';

void main() {
  testWidgets('showToast overlays the message with an icon and auto-dismisses',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showToast(
          context: context,
          message: 'Network error',
          icon: Icons.wifi_off,
          duration: const Duration(seconds: 2),
        ),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // fade-in done

    expect(find.byType(ToastWidget), findsOneWidget);
    expect(find.text('Network error'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);

    // Past duration + reverse animation -> dismissed and removed from overlay.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byType(ToastWidget), findsNothing);
  });

  testWidgets('showToast without icon renders text only', (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showToast(
          context: context,
          message: 'Plain message',
          duration: const Duration(seconds: 2),
        ),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Plain message'), findsOneWidget);
    expect(
      find.descendant(
          of: find.byType(ToastWidget), matching: find.byType(Icon)),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  });
}

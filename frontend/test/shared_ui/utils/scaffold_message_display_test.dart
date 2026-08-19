import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/utils/scaffold_message_display.dart';

import '../../helpers/test_helper.dart';

void main() {
  testWidgets('showScaffoldMessage shows a themed snackbar with the message',
      (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () =>
            showScaffoldMessage(context: context, message: 'Something failed'),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Something failed'), findsOneWidget);
  });

  testWidgets('sanitizes raw-looking messages before display', (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showScaffoldMessage(
            context: context, message: 'Exception: Something failed'),
        child: const Text('go'),
      ),
    )));

    await tester.tap(find.text('go'));
    await tester.pump();

    expect(find.textContaining('Exception:'), findsNothing);
  });
}

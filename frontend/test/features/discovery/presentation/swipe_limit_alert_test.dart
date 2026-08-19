import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/presentation/swipe_limit_alert.dart';
import 'package:linkup/shared_ui/components/common/confirmation_dialog_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  testWidgets('shows the out-of-likes dialog', (tester) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showSwipeLimitAlert(context),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ConfirmationDialogBuilder), findsOneWidget);
    expect(find.text('OUT OF LIKES FOR TODAY'), findsOneWidget);
    await tester.tap(find.text('GOT IT'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmationDialogBuilder), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/components/common/confirmation_dialog_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  Future<void> show(
    WidgetTester tester,
    ConfirmationDialogBuilder dialog,
  ) async {
    await tester.pumpWidget(buildTestWidget(Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => ConfirmationDialogBuilder.show<void>(context, dialog),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, message and icon; confirm fires and closes',
      (tester) async {
    var confirmed = false;
    await show(
      tester,
      ConfirmationDialogBuilder(
        icon: Icons.delete,
        title: 'Delete account',
        message: 'This cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Keep',
        onConfirm: () => confirmed = true,
      ),
    );

    expect(find.text('DELETE ACCOUNT'), findsOneWidget);
    expect(find.text('This cannot be undone.'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    await tester.tap(find.text('DELETE'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    expect(find.byType(ConfirmationDialogBuilder), findsNothing);
  });

  testWidgets('cancel fires onCancel and closes', (tester) async {
    var cancelled = false;
    await show(
      tester,
      ConfirmationDialogBuilder(
        icon: Icons.logout,
        title: 'Log out',
        message: 'Sure?',
        cancelText: 'Stay',
        onCancel: () => cancelled = true,
      ),
    );

    await tester.tap(find.text('STAY'));
    await tester.pumpAndSettle();
    expect(cancelled, isTrue);
  });

  testWidgets('primaryOnTop: false renders cancel above confirm',
      (tester) async {
    await show(
      tester,
      const ConfirmationDialogBuilder(
        icon: Icons.warning,
        title: 'Careful',
        message: 'msg',
        confirmText: 'Go',
        cancelText: 'Back',
        primaryOnTop: false,
      ),
    );
    final cancelY = tester.getTopLeft(find.text('BACK')).dy;
    final confirmY = tester.getTopLeft(find.text('GO')).dy;
    expect(cancelY, lessThan(confirmY));
  });

  testWidgets('horizontal layout renders default actions row', (tester) async {
    await show(
      tester,
      const ConfirmationDialogBuilder(
        icon: Icons.info,
        title: 'Info',
        message: 'msg',
        confirmText: 'Ok',
        cancelText: 'No',
        verticalButtons: false,
      ),
    );
    expect(find.text('Ok'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    await tester.tap(find.text('Ok'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmationDialogBuilder), findsNothing);
  });

  testWidgets('custom content widget replaces the message', (tester) async {
    await show(
      tester,
      const ConfirmationDialogBuilder(
        icon: Icons.tune,
        title: 'Custom',
        cancelText: 'Close',
        content: Text('custom body'),
      ),
    );
    expect(find.text('custom body'), findsOneWidget);
  });
}

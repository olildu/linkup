import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/presentation/screens/uploading_overlay.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  testWidgets('fades in with a default spinner and the text', (tester) async {
    await tester
        .pumpWidget(buildTestWidget(const CustomOverlay(text: 'Uploading')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Uploading'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders a custom icon instead of the spinner', (tester) async {
    await tester.pumpWidget(buildTestWidget(const CustomOverlay(
      text: 'Done',
      iconOrLoader: Icon(Icons.check_circle),
    )));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

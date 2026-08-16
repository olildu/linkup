import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/button_builder.dart';

import '../../../test_helper.dart';

void main() {
  group('ButtonBuilder Tests', () {
    testWidgets('Renders text and calls onPressed when enabled', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          ButtonBuilder(
            text: 'Test Button',
            onPressed: () {
              wasPressed = true;
            },
            isEnabled: true,
          ),
        ),
      );

      // Pump once more to resolve the ScreenUtilInit builder
      await tester.pumpAndSettle();

      expect(find.text('Test Button'), findsOneWidget);

      await tester.tap(find.text('Test Button'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('Does not call onPressed when disabled', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          ButtonBuilder(
            text: 'Disabled Button',
            onPressed: () {
              wasPressed = true;
            },
            isEnabled: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the button (it should still find the text even if disabled)
      await tester.tap(find.text('Disabled Button'));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(ButtonBuilder(text: 'Loading...', onPressed: () {}, isLoading: true)));

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Loading...'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

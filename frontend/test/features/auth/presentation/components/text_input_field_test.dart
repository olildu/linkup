import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/components/text_input_field.dart';
import '../../../../helpers/test_helper.dart'; // Assume test_helper.dart defines buildTestWidget

void main() {
  group('TextInputField (Login)', () {
    late TextEditingController controller;
    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    testWidgets(
      'Toggles obscureText state and icon when toggleObscure is provided',
      (tester) async {
        bool obscureState = true;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return buildTestWidget(
                TextInputField(
                  label: 'Password',
                  hintText: 'Enter password',
                  controller: controller,
                  obscureText: obscureState,
                  toggleObscure: () =>
                      setState(() => obscureState = !obscureState),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial check: Text should be obscured, icon should be visibility_off
        expect(
          tester.widget<TextField>(find.byType(TextField)).obscureText,
          isTrue,
        );
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);

        // 2. Tap the toggle icon
        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // 3. Post-tap check: Text should be visible, icon should be visibility
        expect(
          tester.widget<TextField>(find.byType(TextField)).obscureText,
          isFalse,
        );
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      },
    );

    testWidgets('Applies error border style when hasError is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          TextInputField(
            label: 'Email',
            hintText: 'Enter email',
            controller: controller,
            hasError: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check the border color for error state (red)
      final textFieldWidget = tester.widget<TextField>(find.byType(TextField));
      final enabledBorder =
          textFieldWidget.decoration!.enabledBorder as OutlineInputBorder;

      // The error color is Color.fromARGB(255, 244, 21, 5) which is red.
      expect(
        (enabledBorder.borderSide.color.r * 255.0).round(),
        greaterThan(200),
      );
      expect((enabledBorder.borderSide.color.g * 255.0).round(), lessThan(30));
    });
  });
}

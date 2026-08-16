import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/presentation/components/otp_input_field.dart';
import '../../../test_helper.dart';

void main() {
  group('OtpInputField', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());

    testWidgets('renders correctly with label and hint', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          OtpInputField(
            label: 'Enter Code',
            hintText: '000000',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Enter Code'), findsOneWidget);
      expect(find.text('000000'), findsOneWidget);
    });

    testWidgets('shows error color on border when hasError is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          OtpInputField(
            label: 'OTP',
            hintText: '000',
            controller: controller,
            hasError: true,
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final border = textField.decoration!.enabledBorder as OutlineInputBorder;

      // Verify Red Error Color
      expect((border.borderSide.color.r * 255.0).round(), greaterThan(200));
    });
  });
}

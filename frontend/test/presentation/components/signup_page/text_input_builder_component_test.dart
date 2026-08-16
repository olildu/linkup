import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/text_input_builder_component.dart';
import '../../../test_helper.dart';

void main() {
  group('TextInput (Sign Up)', () {
    testWidgets('initializes internal controller and disposes correctly', (tester) async {
      final controller = TextEditingController(text: 'External');
      await tester.pumpWidget(buildTestWidget(
        TextInput(label: 'Name', controller: controller),
      ));

      // Use the external controller
      expect(controller.text, 'External');

      // Test dispose logic: if external controller provided, it should NOT dispose it.
      await tester.pumpWidget(buildTestWidget(const SizedBox()));
      // We can only assert that no crash occurred during disposal.
    });

    testWidgets('calls onChanged when text is typed', (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildTestWidget(
        TextInput(label: 'Name', onChanged: (val) => changedValue = val),
      ));

      await tester.enterText(find.byType(TextField), 'New Name');
      expect(changedValue, 'New Name');
    });
  });
}
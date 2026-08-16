import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/common/text_field_builder.dart';
import '../../../test_helper.dart';

void main() {
  group('TextFieldBuilder', () {
    testWidgets('renders with initial value and calls onChanged', (tester) async {
      String? changedValue;
      const initialValue = 'Initial text';

      await tester.pumpWidget(buildTestWidget(TextFieldBuilder(hintText: 'Enter text', initialValue: initialValue, onChanged: (val) => changedValue = val)));
      await tester.pumpAndSettle();

      // Check initial value
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, initialValue);

      // Simulate typing
      await tester.enterText(find.byType(TextField), 'New Content');
      expect(changedValue, 'New Content');
    });

    testWidgets('respects maxLines property', (tester) async {
      await tester.pumpWidget(buildTestWidget(TextFieldBuilder(hintText: 'Multiline', maxLines: 7)));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 7);
    });
  });
}

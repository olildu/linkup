import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/picker_builder_component.dart';
import '../../../test_helper.dart';

void main() {
  group('BuildPicker', () {
    late FixedExtentScrollController controller;
    final items = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];

    setUp(() => controller = FixedExtentScrollController());
    tearDown(() => controller.dispose());

    testWidgets('initializes to middle index if no selectedIndex provided', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SizedBox(
          height: 300,
          child: BuildPicker(controller: controller, items: items, onSelectedItemChanged: (_) {}),
        ),
      ));
      await tester.pumpAndSettle();

      // Middle index of 5 items is index 2 ("Item 3")
      // ListWheelScrollView doesn't easily expose current index in tests, 
      // but we can check the styling of the central item.
      final textWidget = tester.widget<Text>(find.text('Item 3'));
      // Check if the middle item has the bold style (default selected style)
      expect(textWidget.style?.fontWeight, FontWeight.bold); 
    });

    testWidgets('uses provided selectedIndex on initialization', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        SizedBox(
          height: 300,
          child: BuildPicker(
            controller: controller, 
            items: items, 
            onSelectedItemChanged: (_) {},
            selectedIndex: 4, // Last item
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('Item 5'));
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });
  });
}
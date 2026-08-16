import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/option_builder.dart';
import 'package:linkup/presentation/constants/colors.dart';
import '../../../test_helper.dart';

void main() {
  group('OptionBuilder', () {
    final options = ['Option A', 'Option B', 'Option C'];

    testWidgets('correctly handles currentOption property on init', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        OptionBuilder(options: options, onChanged: (_) {}, currentOption: 'Option C'),
      ));
      await tester.pumpAndSettle();

      // Check if Option C is marked as selected (AppColors.primary)
      final optionCWidget = tester.widget<AnimatedContainer>(
        find.ancestor(of: find.text('Option C'), matching: find.byType(AnimatedContainer)),
      );
      final decorationC = optionCWidget.decoration as BoxDecoration;
      expect(decorationC.color, AppColors.primary);
      
      // Check if Option A is unselected
      final optionAWidget = tester.widget<AnimatedContainer>(
        find.ancestor(of: find.text('Option A'), matching: find.byType(AnimatedContainer)),
      );
      final decorationA = optionAWidget.decoration as BoxDecoration;
      expect(decorationA.color, AppColors.notSelected);
    });

    testWidgets('calls onChanged when an option is tapped', (tester) async {
      String? selectedOption;
      await tester.pumpWidget(buildTestWidget(
        OptionBuilder(options: options, onChanged: (val) => selectedOption = val),
      ));

      // Tap 'Option B'
      await tester.tap(find.text('Option B'));
      await tester.pump(); 

      expect(selectedOption, 'Option B');
    });
  });
}
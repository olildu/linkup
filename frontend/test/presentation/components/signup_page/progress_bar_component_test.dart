import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/progress_bar_component.dart';
import 'package:linkup/presentation/constants/colors.dart';
import '../../../test_helper.dart';

void main() {
  group('ProgressBarComponent Widget Tests', () {
    const totalSteps = 4;
    const initialIndex = 1;
    final primaryColor = AppColors.primary;
    final notSelectedColor = AppColors.notSelected;

    testWidgets('Renders all bars correctly in initial state', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        ProgressBarComponent(currentIndex: initialIndex, totalSteps: totalSteps),
      ));
      await tester.pumpAndSettle();

      // Assert: Find the correct number of Expanded/Container widgets (the bars)
      expect(find.byType(Expanded), findsNWidgets(totalSteps));

      // Check the color of the first bar (index 0 - completed)
      final container0 = tester.widget<Container>(
        find.descendant(of: find.byType(Expanded).at(0), matching: find.byType(Container)),
      );
      expect((container0.decoration as BoxDecoration).color, primaryColor);

      // Check the color of the last bar (index 3 - unselected)
      final container3 = tester.widget<Container>(
        find.descendant(of: find.byType(Expanded).at(3), matching: find.byType(Container)),
      );
      expect((container3.decoration as BoxDecoration).color, notSelectedColor);
    });

    testWidgets('Correctly animates colors when currentIndex is changed', (WidgetTester tester) async {
      // 1. Initial State: index 1
      await tester.pumpWidget(buildTestWidget(
        ProgressBarComponent(key: const Key('progress'), currentIndex: 1, totalSteps: totalSteps, animationDuration: const Duration(milliseconds: 100)),
      ));
      await tester.pumpAndSettle();

      // 2. Update: Change currentIndex to 3 (simulates advancing flow)
      await tester.pumpWidget(buildTestWidget(
        ProgressBarComponent(key: const Key('progress'), currentIndex: 3, totalSteps: totalSteps, animationDuration: const Duration(milliseconds: 100)),
      ));

      // Advance halfway (t=50ms)
      await tester.pump(const Duration(milliseconds: 50)); 
      
      // Bar 3: The 'current' bar, should be somewhere between notSelected and primary.
      final container3 = tester.widget<Container>(
        find.descendant(of: find.byType(Expanded).at(3), matching: find.byType(Container)),
      );
      final color3 = (container3.decoration as BoxDecoration).color;
      
      // We expect the color to be neither fully inactive nor fully active yet.
      expect(color3, isNot(primaryColor));
      expect(color3, isNot(notSelectedColor));

      // Advance to end of animation
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Final state: Bar 3 is completed/current, should be primary color
      final finalContainer3 = tester.widget<Container>(
        find.descendant(of: find.byType(Expanded).at(3), matching: find.byType(Container)),
      );
      expect((finalContainer3.decoration as BoxDecoration).color, primaryColor);
    });
  });
}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/common/range_slider_builder.dart';
import '../../../test_helper.dart';

void main() {
  group('RangeSliderBuilder', () {
    const initialValues = RangeValues(20, 80);
    const min = 0.0;
    const max = 100.0;

    testWidgets('renders RangeSlider and updates state on drag', (tester) async {
      RangeValues? finalValues;

      await tester.pumpWidget(buildTestWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return RangeSliderBuilder(
              values: initialValues,
              min: min,
              max: max,
              divisions: 10,
              onChanged: (newValues) {
                finalValues = newValues;
                setState(() {}); // Simulate parent re-building
              },
            );
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(RangeSlider), findsOneWidget);

      // Simulate dragging the end thumb (at 80) to 90
      final sliderFinder = find.byType(RangeSlider);
      await tester.drag(sliderFinder, const Offset(50, 0)); // Arbitrary drag distance

      await tester.pumpAndSettle();

      // Check if onChanged was called and internal state updated
      expect(finalValues, isNotNull);
      // We can't know the exact new value without geometry, but we know it changed.
      expect(finalValues!.start, equals(initialValues.start));
      expect(finalValues!.end, isNot(equals(initialValues.end)));
    });
  });
}
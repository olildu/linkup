import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/city_lookup.dart';
import 'package:linkup/presentation/components/signup_page/option_builder.dart';
import '../../../test_helper.dart';

void main() {
  group('CityLookup Widget Test', () {
    
    // Wrapper providing finite constraints.
    // Because CityLookup now uses Expanded, the parent MUST have a defined height.
    Widget buildCityLookupWrapper({required Function(String) onChanged}) {
      return SizedBox(
        width: 400,
        height: 600, // Provides the boundary for the internal Expanded widget
        child: CityLookup(onChanged: onChanged),
      );
    }

    testWidgets('renders TextInput and initial cities', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        buildCityLookupWrapper(onChanged: (_) {}),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Search your hometown'), findsOneWidget);
      expect(find.text('Mumbai, Maharashtra'), findsOneWidget);
      expect(find.byType(OptionBuilder), findsOneWidget);
    });

    testWidgets('triggers onChanged when a city option is tapped', (tester) async {
      String? selectedCity;

      await tester.pumpWidget(buildTestWidget(
        buildCityLookupWrapper(onChanged: (val) => selectedCity = val),
      ));
      await tester.pumpAndSettle();

      // Tap an option
      await tester.tap(find.text('Jaipur, Rajasthan'));
      await tester.pump();

      // Verify callback and text field update
      expect(selectedCity, 'Jaipur, Rajasthan');
      final textField = tester.widget<TextField>(
        find.descendant(of: find.byType(CityLookup), matching: find.byType(TextField))
      );
      expect(textField.controller!.text, 'Jaipur, Rajasthan');
    });
  });
}
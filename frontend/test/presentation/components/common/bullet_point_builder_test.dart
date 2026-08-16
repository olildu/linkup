import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/common/bullet_point_builder.dart';
import '../../../test_helper.dart';

void main() {
  group('BulletPointBuilder', () {
    final items = ['Rule one', 'Rule two', 'Rule three with long text'];

    testWidgets('renders correct number of items and icons', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        BulletPointBuilder(items: items),
      ));

      // Check for all text items
      expect(find.text('Rule one'), findsOneWidget);
      expect(find.text('Rule two'), findsOneWidget);
      expect(find.text('Rule three with long text'), findsOneWidget);
      
      // Check for the icon used as a bullet point (Icons.arrow_right_rounded)
      expect(find.byIcon(Icons.arrow_right_rounded), findsNWidgets(items.length));
    });
  });
}
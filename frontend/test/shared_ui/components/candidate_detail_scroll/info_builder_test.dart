import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/shared_ui/components/candidate_detail_scroll/info_builder.dart';

import '../../../helpers/test_helper.dart';

void main() {
  testWidgets('renders text with an icon when provided', (tester) async {
    await tester.pumpWidget(buildTestWidget(
        const InfoBuilder(text: '170 cm', icon: Icons.straighten)));
    expect(find.text('170 cm'), findsOneWidget);
    expect(find.byIcon(Icons.straighten), findsOneWidget);
  });

  testWidgets('renders text only when no icon is given', (tester) async {
    await tester
        .pumpWidget(buildTestWidget(const InfoBuilder(text: 'Reading')));
    expect(find.text('Reading'), findsOneWidget);
    expect(find.byType(Icon), findsNothing);
  });
}

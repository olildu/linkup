import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/presentation/screens/full_screen_image_page.dart';
import 'package:linkup/shared_ui/components/candidate_detail_scroll/candidate_detail_builder.dart';
import 'package:linkup/shared_ui/components/candidate_detail_scroll/info_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helper.dart';

void main() {
  Future<void> pumpBuilder(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidget(
          SingleChildScrollView(
            child: CandidateDetailBuilder(
              availableHeight: 600,
              candidate: makeCandidate(username: 'alice'),
            ),
          ),
        )));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('renders the candidate name, about and info chips',
      (tester) async {
    await pumpBuilder(tester);
    expect(find.textContaining('alice'), findsWidgets);
    expect(find.text('about me'), findsWidgets);
    expect(find.byType(InfoBuilder), findsWidgets);
  });

  testWidgets('tapping the hero photo opens the full screen viewer',
      (tester) async {
    await pumpBuilder(tester);
    await mockNetworkImagesFor(() async {
      await tester.tap(find.byType(GestureDetector).first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
    expect(find.byType(FullScreenImageScreen), findsOneWidget);
  });
}

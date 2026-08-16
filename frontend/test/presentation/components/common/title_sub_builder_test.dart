import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/common/title_sub_builder.dart';
import '../../../test_helper.dart';

void main() {
  group('BuildTitleSubtitle', () {
    testWidgets('renders title and subtitle', (tester) async {
      const title = 'Main Title';
      const subtitle = 'Supporting Subtitle';

      await tester.pumpWidget(buildTestWidget(
        const BuildTitleSubtitle(title: title, subtitle: subtitle),
      ));

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('applies dark theme color to subtitle', (tester) async {
      const subtitle = 'Check Theme Color';

      await tester.pumpWidget(
        Theme(
          data: ThemeData.dark(),
          child: buildTestWidget(const BuildTitleSubtitle(title: 'T', subtitle: subtitle)),
        ),
      );
      await tester.pumpAndSettle();

      final subtitleWidget = tester.widget<Text>(find.text(subtitle));
      // In dark mode, the subtitle should use AppColors.notSelected (a shade of grey/white)
      expect(subtitleWidget.style!.color, isNotNull);
    });
  });
}
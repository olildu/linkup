import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/signup_page/page_title_builder_component.dart';
import 'package:linkup/presentation/constants/colors.dart';
import '../../../test_helper.dart';

void main() {
  group('PageTitle', () {
    testWidgets('highlights a single word correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const PageTitle(
          inputText: "Hello Beautiful World",
          highlightWord: "Beautiful",
        ),
      ));

      // Find RichText widget
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      final richText = tester.widget<RichText>(richTextFinder);
      final textSpan = richText.text as TextSpan;

      // Verify that the word "Beautiful" has the primary color and w900 weight
      bool foundHighlight = false;
      textSpan.visitChildren((span) {
        if (span is TextSpan && span.text == 'Beautiful ') {
          if (span.style?.color == AppColors.primary && span.style?.fontWeight == FontWeight.w900) {
            foundHighlight = true;
          }
        }
        return true;
      });

      expect(foundHighlight, isTrue);
    });

    testWidgets('renders subText when provided', (tester) async {
      const subText = "This is a subtitle.";
      await tester.pumpWidget(buildTestWidget(
        const PageTitle(
          inputText: "Title",
          highlightWord: "Title",
          subText: subText,
        ),
      ));

      expect(find.text(subText), findsOneWidget);
    });
  });
}
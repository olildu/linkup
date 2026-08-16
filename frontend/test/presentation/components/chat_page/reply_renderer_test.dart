import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/presentation/components/chat_page/reply_renderer.dart';
import '../../../test_helper.dart';

void main() {
  group('ReplyRenderer', () {
    testWidgets('renders text and bar for a message sent by me', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ReplyRenderer(
          isSentByMe: true,
          isReversed: false,
          replyMessageContent: Text('My Reply'),
          barColor: Colors.blue,
        ),
      ));

      expect(find.text('You replied'), findsOneWidget);
      // For sent messages (isReversed: false), the layout is [Content, Gap, Bar]
      final row = tester.widget<Row>(find.byType(Row));
      final indicatorBar = row.children.last;
      expect(indicatorBar, isA<Padding>());
      
      // Ensure the content is visible
      expect(find.text('My Reply'), findsOneWidget);
    });

    testWidgets('renders text and bar for a message received from another user', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ReplyRenderer(
          isSentByMe: false,
          isReversed: true, // Reversed layout for received
          replyMessageContent: Text('Their Reply'),
          barColor: Colors.grey,
        ),
      ));

      expect(find.text('Replied to you'), findsOneWidget);
      // For received messages (isReversed: true), the layout is [Bar, Gap, Content]
      final row = tester.widget<Row>(find.byType(Row));
      final indicatorBar = row.children.first;
      expect(indicatorBar, isA<Padding>());
      
      expect(find.text('Their Reply'), findsOneWidget);
    });
  });
}
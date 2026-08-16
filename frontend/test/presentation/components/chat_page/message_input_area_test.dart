import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/data/models/reply_model.dart';
import 'package:linkup/features/messaging/presentation/components/message_input_area.dart';
import '../../../test_helper.dart';

void main() {
  group('MessageInputArea', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());

    testWidgets('shows camera icon when not typing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          MessageInputArea(
            messageController: controller,
            isTyping: false,
            replyPayload: null,
            sendMessage: () {},
            handleMedia: (_) {},
            removeReplyPayload: () {},
            userImageMetaData: {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Not typing -> should show camera/media icon set
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsNothing);
    });

    testWidgets('shows send button when typing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          MessageInputArea(
            messageController: controller,
            isTyping: true,
            replyPayload: null,
            sendMessage: () {},
            handleMedia: (_) {},
            removeReplyPayload: () {},
            userImageMetaData: {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Is typing -> should show send button
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
    });

    testWidgets('renders reply payload when provided and removes it on tap', (
      tester,
    ) async {
      bool removed = false;
      final replyPayload = ReplyModel(
        messageID: '1',
        message: 'Original msg',
        userName: 'UserX',
      );

      await tester.pumpWidget(
        buildTestWidget(
          MessageInputArea(
            messageController: controller,
            isTyping: false,
            replyPayload: replyPayload,
            sendMessage: () {},
            handleMedia: (_) {},
            removeReplyPayload: () => removed = true,
            userImageMetaData: {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check reply text visibility
      expect(find.textContaining('Replying to UserX'), findsOneWidget);

      // Check the close/remove button
      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      // Tap the remove button
      await tester.tap(closeButton);
      await tester.pump();

      expect(removed, isTrue);
    });
  });
}

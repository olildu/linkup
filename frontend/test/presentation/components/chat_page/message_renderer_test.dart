// Added missing import: ReplyRenderer
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/presentation/components/chat_page/message_renderer.dart';
import 'package:linkup/presentation/components/chat_page/reply_renderer.dart';
import 'package:get_it/get_it.dart';
import '../../../test_helper.dart';

void main() {
  setUpAll(() {
    GetIt.instance.registerSingleton<int>(123, instanceName: 'user_id');
  });
  tearDownAll(() {
    GetIt.instance.reset();
  });

  final standardMessage = Message(
    id: '1', message: 'Hello World', to: 456, from_: 123, 
    timestamp: DateTime.now(), chatRoomId: 1
  );
  
  final replyMessage = Message(
    id: '2', message: 'I am replying', to: 456, from_: 123, 
    timestamp: DateTime.now(), chatRoomId: 1, replyID: '1'
  );

  testWidgets('renders replied message content when replyID is present', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      MessageRenderer(
        message: replyMessage,
        messages: [standardMessage, replyMessage],
        isSentByMe: true,
        messageBorderRadius: BorderRadius.circular(8),
        color: Colors.blue,
        isOnlyEmoji: false,
      ),
    ));
    await tester.pumpAndSettle();

    // Check for the ReplyRenderer widget
    expect(find.byType(ReplyRenderer), findsOneWidget);
    // Check for the original message content being rendered as a reply
    expect(find.textContaining('Hello World'), findsOneWidget); 
    // Check for the main message content
    expect(find.text('I am replying'), findsOneWidget); 
  });

  testWidgets('renders plain text message correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget(
      MessageRenderer(
        message: standardMessage,
        messages: [standardMessage],
        isSentByMe: false, // Received message
        messageBorderRadius: BorderRadius.circular(8),
        color: Colors.grey,
        isOnlyEmoji: false,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Hello World'), findsOneWidget);
  });
}
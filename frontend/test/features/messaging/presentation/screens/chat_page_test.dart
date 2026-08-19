import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';
import 'package:linkup/features/messaging/presentation/bloc/chats_bloc.dart';
import 'package:linkup/features/messaging/presentation/components/message_input_area.dart';
import 'package:linkup/features/messaging/presentation/screens/chat_page.dart';
import 'package:linkup/shared_ui/components/common/confirmation_dialog_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    registerBlocEventFallbacks();
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  late MockChatsBloc chatsBloc;
  late MockConnectionsBloc connectionsBloc;

  const imageMeta = <String, dynamic>{
    'url': 'https://cdn.test/bob.jpg',
    'file_key': 'fk-bob',
    'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
  };

  Message message({
    String id = 'm1',
    String text = 'hello',
    int from = 2,
    int to = 1,
    bool isSeen = false,
  }) =>
      Message(
        id: id,
        message: text,
        to: to,
        from_: from,
        chatRoomId: 10,
        isSeen: isSeen,
        timestamp: DateTime(2026, 1, 1, 12),
      );

  setUp(() async {
    chatsBloc = MockChatsBloc();
    connectionsBloc = MockConnectionsBloc();
    when(() => chatsBloc.add(any())).thenReturn(null);
    when(() => connectionsBloc.add(any())).thenReturn(null);
    stubBloc<ConnectionsState>(connectionsBloc, ConnectionsInitial());
    final sl = GetIt.instance;
    await sl.reset();
    sl.registerSingleton<int>(1, instanceName: 'user_id');
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    ignoreDeactivatedAncestorErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          const ChatPage(
            currentChatUserId: 2,
            currentUserId: 1,
            userName: 'bob',
            userImageMetaData: imageMeta,
            chatRoomId: 10,
          ),
          providers: [
            BlocProvider<ChatsBloc>.value(value: chatsBloc),
            BlocProvider<ConnectionsBloc>.value(value: connectionsBloc),
          ],
        )));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('loading state shows a spinner', (tester) async {
    stubBloc<ChatsState>(chatsBloc, ChatsLoading());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error state shows the failure text', (tester) async {
    stubBloc<ChatsState>(chatsBloc, ChatsError());
    await pumpPage(tester);
    expect(find.text('Error loading messages'), findsOneWidget);
  });

  testWidgets('initial state shows the empty placeholder', (tester) async {
    stubBloc<ChatsState>(chatsBloc, ChatsInitial());
    await pumpPage(tester);
    expect(find.text('No messages yet'), findsOneWidget);
  });

  testWidgets(
      'loaded chat renders messages, marks them seen and shows the input',
      (tester) async {
    stubBloc<ChatsState>(
        chatsBloc,
        ChatsLoaded(messages: [
          message(id: 'a', text: 'hi from bob'),
          message(id: 'b', text: 'my reply', from: 1, to: 2, isSeen: true),
        ]));
    await pumpPage(tester);

    expect(find.text('hi from bob'), findsOneWidget);
    expect(find.text('my reply'), findsOneWidget);
    expect(find.byType(MessageInputArea), findsOneWidget);
    expect(find.text('Seen'), findsOneWidget);

    final seen = verify(() => connectionsBloc.add(captureAny())).captured;
    expect(seen.whereType<MarkMessagesSeenEvent>().first.chatRoomId, 10);
  });

  testWidgets('typing in the field dispatches SendTypingEvent and sending '
      'dispatches SendMessageEvent', (tester) async {
    stubBloc<ChatsState>(
        chatsBloc, ChatsLoaded(messages: [message()]));
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'typed message');
    await tester.pump();

    var events = verify(() => chatsBloc.add(captureAny())).captured;
    expect(events.whereType<SendTypingEvent>(), isNotEmpty);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    events = verify(() => chatsBloc.add(captureAny())).captured;
    final sent = events.whereType<SendMessageEvent>();
    expect(sent, isNotEmpty);
    expect(sent.first.message.message, 'typed message');
  });

  testWidgets('typing indicator appears when the partner is typing',
      (tester) async {
    stubBloc<ChatsState>(chatsBloc,
        ChatsLoaded(messages: [message()], isTyping: true, typingUserId: 2));
    await pumpPage(tester);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('bob'), findsWidgets);
  });

  testWidgets('menu opens block confirmation dialog', (tester) async {
    stubBloc<ChatsState>(chatsBloc, ChatsLoaded(messages: [message()]));
    await pumpPage(tester);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Block User'), findsOneWidget);
    expect(find.text('Report User'), findsOneWidget);

    await tester.tap(find.text('Block User'));
    await tester.pumpAndSettle();
    expect(find.byType(ConfirmationDialogBuilder), findsOneWidget);
  });
}

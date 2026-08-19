import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';
import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/presentation/bloc/chats_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_socket_services.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeChatSocketServices socket;
  late MockFetchMessagesUseCase fetchMessages;
  late MockGetCachedMessagesUseCase getCached;
  late MockCacheMessageUseCase cacheMessage;
  late MockSaveUnsentMessageUseCase saveUnsent;
  late MockUploadChatMediaUseCase uploadMedia;
  late MockPaginateMessagesUseCase paginate;

  setUpAll(() {
    registerFallbackValue(makeMessage());
    registerFallbackValue(File('/tmp/fallback.png'));
  });

  setUp(() {
    socket = FakeChatSocketServices();
    fetchMessages = MockFetchMessagesUseCase();
    getCached = MockGetCachedMessagesUseCase();
    cacheMessage = MockCacheMessageUseCase();
    saveUnsent = MockSaveUnsentMessageUseCase();
    uploadMedia = MockUploadChatMediaUseCase();
    paginate = MockPaginateMessagesUseCase();
    when(() => cacheMessage(any())).thenAnswer((_) async {});
    when(() => saveUnsent(any())).thenAnswer((_) async {});
  });

  // currentUserId 1 chats with user 2 in room 10.
  ChatsBloc build() => ChatsBloc(
        currentChatUserId: 2,
        currentUserId: 1,
        chatRoomId: 10,
        fetchMessagesUseCase: fetchMessages,
        getCachedMessagesUseCase: getCached,
        cacheMessageUseCase: cacheMessage,
        saveUnsentMessageUseCase: saveUnsent,
        uploadChatMediaUseCase: uploadMedia,
        paginateMessagesUseCase: paginate,
        chatSocket: socket,
      );

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  Message outgoing({String id = 'm-out'}) => Message(
        id: id,
        message: 'hi there',
        to: 2,
        from_: 1,
        chatRoomId: 10,
        timestamp: DateTime(2026, 1, 1),
      );

  group('StartChatsEvent', () {
    test('loads messages, caches the first 20 and reports socket status',
        () async {
      final entities = [makeMessage(id: 'a'), makeMessage(id: 'b')];
      when(() => fetchMessages(10)).thenAnswer((_) async => entities);

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      final state = bloc.state as ChatsLoaded;
      expect(state.messages.map((m) => m.id), ['a', 'b']);
      expect(state.isSocketConnected, isTrue);
      verify(() => cacheMessage(any())).called(2);
      await bloc.close();
    });

    test('falls back to the cache when fetching fails', () async {
      when(() => fetchMessages(10)).thenThrow(Exception('offline'));
      when(() => getCached(10))
          .thenAnswer((_) async => [makeMessage(id: 'cached')]);

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      expect((bloc.state as ChatsLoaded).messages.single.id, 'cached');
      await bloc.close();
    });

    test('emits ChatsError when both fetch and cache fail', () async {
      when(() => fetchMessages(10)).thenThrow(Exception('offline'));
      when(() => getCached(10)).thenThrow(Exception('no cache'));

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      expect(bloc.state, isA<ChatsError>());
      await bloc.close();
    });
  });

  group('SendMessageEvent', () {
    test('sends over the socket and caches when connected', () async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(SendMessageEvent(message: outgoing()));
      await pump();

      expect(socket.sent.single['message_id'], 'm-out');
      final state = bloc.state as ChatsLoaded;
      expect(state.messages.single.isSent, isTrue);
      await bloc.close();
    });

    test('marks the message unsent and saves it when disconnected', () async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      socket.connected = false;
      bloc.add(SendMessageEvent(message: outgoing()));
      await pump();

      expect(socket.sent, isEmpty);
      expect((bloc.state as ChatsLoaded).messages.single.isSent, isFalse);
      verify(() => saveUnsent(any())).called(1);
      await bloc.close();
    });

    test('from a non-loaded state seeds a new ChatsLoaded', () async {
      final bloc = build();
      bloc.add(SendMessageEvent(message: outgoing()));
      await pump();
      expect((bloc.state as ChatsLoaded).messages.single.id, 'm-out');
      await bloc.close();
    });
  });

  group('socket-driven events', () {
    Future<ChatsBloc> loadedBloc() async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();
      return bloc;
    }

    test('incoming message for this chat is appended', () async {
      final bloc = await loadedBloc();
      socket.emitMessage({
        'type': 'chats',
        'chats_type': 'message',
        'message_id': 'in-1',
        'message': 'yo',
        'to': 1,
        'from_': 2,
        'chat_room_id': 10,
      });
      await pump();
      expect((bloc.state as ChatsLoaded).messages.single.id, 'in-1');
      await bloc.close();
    });

    test('message from another conversation is ignored', () async {
      final bloc = await loadedBloc();
      socket.emitMessage({
        'type': 'chats',
        'chats_type': 'message',
        'message_id': 'in-2',
        'message': 'yo',
        'to': 1,
        'from_': 99,
        'chat_room_id': 55,
      });
      await pump();
      expect((bloc.state as ChatsLoaded).messages, isEmpty);
      await bloc.close();
    });

    test('typing from the chat partner toggles isTyping and times out',
        () async {
      final bloc = await loadedBloc();
      socket.emitMessage({
        'type': 'chats',
        'chats_type': 'typing',
        'message': '',
        'to': 1,
        'from_': 2,
        'chat_room_id': 10,
      });
      await pump();
      expect((bloc.state as ChatsLoaded).isTyping, isTrue);

      await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 100));
      expect((bloc.state as ChatsLoaded).isTyping, isFalse);
      await bloc.close();
    });

    test('typing from someone else is ignored', () async {
      final bloc = await loadedBloc();
      socket.emitMessage({
        'type': 'chats',
        'chats_type': 'typing',
        'message': '',
        'to': 1,
        'from_': 99,
        'chat_room_id': 10,
      });
      await pump();
      expect((bloc.state as ChatsLoaded).isTyping, isFalse);
      await bloc.close();
    });

    test('seen event from the partner flips otherUserSeenMsg', () async {
      final bloc = await loadedBloc();
      socket.emitMessage({
        'type': 'chats',
        'chats_type': 'seen',
        'from_': 2,
        'message_id': 'x',
      });
      await pump();
      expect((bloc.state as ChatsLoaded).otherUserSeenMsg, isTrue);
      await bloc.close();
    });

    test('reconnect status triggers a silent resync', () async {
      final bloc = await loadedBloc();
      socket.emitStatus(true);
      await pump();
      verify(() => fetchMessages(10)).called(2);
      await bloc.close();
    });
  });

  group('MarkMessageAsSeenEvent', () {
    test('marks the message and notifies the partner over the socket',
        () async {
      when(() => fetchMessages(10))
          .thenAnswer((_) async => [makeMessage(id: 'in-1', from: 2, to: 1)]);
      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(MarkMessageAsSeenEvent(messageId: 'in-1'));
      await pump();

      expect((bloc.state as ChatsLoaded).messages.single.isSeen, isTrue);
      expect(socket.sent.single['chats_type'], 'seen');
      expect(socket.sent.single['message_id'], 'in-1');

      // Second mark on an already-seen message is a no-op.
      bloc.add(MarkMessageAsSeenEvent(messageId: 'in-1'));
      await pump();
      expect(socket.sent, hasLength(1));
      await bloc.close();
    });
  });

  group('SendTypingEvent', () {
    test('sends one typing frame and throttles repeats', () async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(SendTypingEvent(currentChatUserId: 2));
      bloc.add(SendTypingEvent(currentChatUserId: 2));
      await pump();

      expect(socket.sent.where((m) => m['chats_type'] == 'typing'),
          hasLength(1));
      await bloc.close();
    });
  });

  group('UploadMediaChatEvent', () {
    test('uploads and sends a media message', () async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      when(() => uploadMedia(any(), MessageType.image)).thenAnswer(
          (_) async => {'file_key': 'k1', 'metadata': {'w': 1}});

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(UploadMediaChatEvent(
          file: File('/tmp/pic.png'), mediaType: MessageType.image));
      await pump(600); // upload handler waits 500ms before sending

      expect(socket.sent.single['media']['file_key'], 'k1');
      await bloc.close();
    });

    test('emits ChatsError when the upload fails', () async {
      when(() => fetchMessages(10)).thenAnswer((_) async => <MessageEntity>[]);
      when(() => uploadMedia(any(), MessageType.image))
          .thenThrow(Exception('too big'));

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(UploadMediaChatEvent(
          file: File('/tmp/pic.png'), mediaType: MessageType.image));
      await pump();

      expect(bloc.state, isA<ChatsError>());
      await bloc.close();
    });
  });

  group('PaginateAddMessagesEvent', () {
    test('prepends the older page of messages', () async {
      final ts = DateTime(2026, 1, 1);
      when(() => fetchMessages(10))
          .thenAnswer((_) async => [makeMessage(id: 'new')]);
      when(() => paginate(
            chatRoomId: 10,
            lastMessageId: 'new',
            lastMessageTimeStamp: ts,
          )).thenAnswer((_) async => [makeMessage(id: 'old')]);

      final bloc = build();
      bloc.add(StartChatsEvent());
      await pump();

      bloc.add(PaginateAddMessagesEvent(
          chatRoomId: 10, lastMessageID: 'new', lastMessageTimeStamp: ts));
      await pump();

      final state = bloc.state as ChatsLoaded;
      expect(state.messages.map((m) => m.id), ['old', 'new']);
      expect(state.isFetchingPaginatedMessages, isFalse);
      await bloc.close();
    });
  });
}

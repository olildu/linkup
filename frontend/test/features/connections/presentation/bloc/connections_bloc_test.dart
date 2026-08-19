import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_socket_services.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeChatSocketServices chatSocket;
  late FakeConnectionsSocketService connectionsSocket;
  late MockGetConnectionsUseCase getConnections;
  late MockCacheConnectionsUseCase cacheConnections;
  late MockGetCachedConnectionsUseCase getCachedConnections;
  late MockBlockUserUseCase blockUser;
  late MockReportUserUseCase reportUser;

  setUp(() {
    chatSocket = FakeChatSocketServices();
    connectionsSocket = FakeConnectionsSocketService();
    getConnections = MockGetConnectionsUseCase();
    cacheConnections = MockCacheConnectionsUseCase();
    getCachedConnections = MockGetCachedConnectionsUseCase();
    blockUser = MockBlockUserUseCase();
    reportUser = MockReportUserUseCase();
    when(() => cacheConnections(any())).thenAnswer((_) async {});
  });

  ConnectionsBloc build() => ConnectionsBloc(
        getConnectionsUseCase: getConnections,
        cacheConnectionsUseCase: cacheConnections,
        getCachedConnectionsUseCase: getCachedConnections,
        blockUserUseCase: blockUser,
        reportUserUseCase: reportUser,
        chatSocket: chatSocket,
        connectionsSocket: connectionsSocket,
        resolveCurrentUserId: () => 1,
      );

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  void stubLoaded({int chatRoomId = 10}) {
    when(() => getConnections()).thenAnswer((_) async => (
          matches: [makeMatchesConnection(id: 4)],
          chats: [makeChatConnection(id: 3, chatRoomId: chatRoomId)],
        ));
  }

  test('LoadConnectionsEvent(showLoading: true) emits Loading then Loaded and caches',
      () async {
    stubLoaded();
    final bloc = build();
    final states = <ConnectionsState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadConnectionsEvent(showLoading: true));
    await pump();

    expect(states, [isA<ConnectionsLoading>(), isA<ConnectionsLoaded>()]);
    verify(() => cacheConnections(any())).called(1);
    await bloc.close();
  });

  test('falls back to cached connections when HTTP fails', () async {
    when(() => getConnections()).thenThrow(Exception('offline'));
    when(() => getCachedConnections())
        .thenAnswer((_) async => [makeChatConnection(id: 3)]);

    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    final state = bloc.state as ConnectionsLoaded;
    expect(state.chats, hasLength(1));
    expect(state.matches, isEmpty);
    await bloc.close();
  });

  test('emits ConnectionsError when even the cache read fails', () async {
    when(() => getConnections()).thenThrow(Exception('offline'));
    when(() => getCachedConnections()).thenThrow(Exception('no cache'));

    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    expect(bloc.state, isA<ConnectionsError>());
    await bloc.close();
  });

  test('incoming chat message reorders the chat and bumps unseen counter',
      () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    chatSocket.emitMessage({
      'type': 'chats',
      'chats_type': 'message',
      'message': 'new text',
      'to': 1,
      'from_': 3,
      'chat_room_id': 10,
    });
    await pump();

    final state = bloc.state as ConnectionsLoaded;
    expect(state.chats.first.message, 'new text');
    expect(state.chats.first.unseenCounter, 3); // 2 + 1
    await bloc.close();
  });

  test('own outgoing message does not bump the unseen counter', () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    chatSocket.emitMessage({
      'type': 'chats',
      'chats_type': 'message',
      'message': 'mine',
      'to': 3,
      'from_': 1, // current user
      'chat_room_id': 10,
    });
    await pump();

    expect((bloc.state as ConnectionsLoaded).chats.first.unseenCounter, 2);
    await bloc.close();
  });

  test('typing message shows preview then reverts after the timer', () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    chatSocket.emitMessage({
      'type': 'chats',
      'chats_type': 'typing',
      'message': 'typing...',
      'to': 1,
      'from_': 3,
      'chat_room_id': 10,
    });
    await pump();
    expect((bloc.state as ConnectionsLoaded).chats.first.message, 'typing...');

    // The revert timer runs after 3 seconds.
    await Future<void>.delayed(const Duration(seconds: 3, milliseconds: 100));
    expect((bloc.state as ConnectionsLoaded).chats.first.message,
        'last message');
    await bloc.close();
  });

  test('message for an unknown chat room triggers a silent reload', () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    when(() => getConnections()).thenAnswer((_) async => (
          matches: <MatchesConnectionEntity>[],
          chats: [
            makeChatConnection(id: 3, chatRoomId: 10),
            makeChatConnection(id: 9, chatRoomId: 99),
          ],
        ));

    chatSocket.emitMessage({
      'type': 'chats',
      'chats_type': 'message',
      'message': 'hey',
      'to': 1,
      'from_': 9,
      'chat_room_id': 99,
    });
    await pump();

    expect((bloc.state as ConnectionsLoaded).chats, hasLength(2));
    await bloc.close();
  });

  test('connections-reload socket message reloads silently', () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    connectionsSocket.emitMessage({'type': 'connections-reload'});
    await pump();

    verify(() => getConnections()).called(2);
    await bloc.close();
  });

  test('MarkMessagesSeenEvent resets the unseen counter', () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    bloc.add(MarkMessagesSeenEvent(chatRoomId: 10));
    await pump();

    expect((bloc.state as ConnectionsLoaded).chats.first.unseenCounter, 0);
    await bloc.close();
  });

  test('BlockUserEvent removes the chat and match optimistically', () async {
    stubLoaded();
    when(() => blockUser(3)).thenAnswer((_) async {});
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    bloc.add(BlockUserEvent(userIdToBlock: 3, chatRoomId: 10));
    await pump();

    final state = bloc.state as ConnectionsLoaded;
    expect(state.chats, isEmpty);
    verify(() => blockUser(3)).called(1);
    await bloc.close();
  });

  test('failed block reloads connections to restore state', () async {
    stubLoaded();
    when(() => blockUser(3)).thenThrow(Exception('boom'));
    final bloc = build();
    bloc.add(LoadConnectionsEvent());
    await pump();

    bloc.add(BlockUserEvent(userIdToBlock: 3, chatRoomId: 10));
    await pump();

    verify(() => getConnections()).called(2);
    await bloc.close();
  });

  test('ReportUserEvent delegates and swallows failures', () async {
    when(() => reportUser(3, 'spam')).thenAnswer((_) async {});
    final bloc = build();
    bloc.add(ReportUserEvent(userIdToReport: 3, reason: 'spam'));
    await pump();
    verify(() => reportUser(3, 'spam')).called(1);

    when(() => reportUser(3, 'again')).thenThrow(Exception('boom'));
    bloc.add(ReportUserEvent(userIdToReport: 3, reason: 'again'));
    await pump();
    await bloc.close();
  });
}

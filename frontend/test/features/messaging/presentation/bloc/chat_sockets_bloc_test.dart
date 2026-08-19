import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/presentation/bloc/chat_sockets_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fake_socket_services.dart';
import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late FakeChatSocketServices socket;
  late MockGetUnsentMessagesUseCase getUnsent;
  late MockDeleteUnsentByMessageIdUseCase deleteUnsent;

  setUp(() {
    socket = FakeChatSocketServices();
    getUnsent = MockGetUnsentMessagesUseCase();
    deleteUnsent = MockDeleteUnsentByMessageIdUseCase();
    when(() => getUnsent()).thenAnswer((_) async => []);
    when(() => deleteUnsent(any())).thenAnswer((_) async {});
  });

  ChatSocketsBloc build() => ChatSocketsBloc(
        getUnsentMessagesUseCase: getUnsent,
        deleteUnsentByMessageIdUseCase: deleteUnsent,
        chatSocket: socket,
      );

  test('LoadChatSocketsEvent emits Connecting then Connected', () async {
    final bloc = build();
    final states = <ChatSocketsState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadChatSocketsEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states,
        [isA<ChatSocketsConnecting>(), isA<ChatSocketsConnected>()]);
    expect(socket.connectCalled, isTrue);
    await bloc.close();
  });

  test('connect failure emits ChatSocketsError', () async {
    socket.connectError = Exception('down');
    final bloc = build();
    final states = <ChatSocketsState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadChatSocketsEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states.last, isA<ChatSocketsError>());
    await bloc.close();
  });

  test('reconnect resends unsent messages and deletes them from cache',
      () async {
    final unsentMessage = makeMessage(id: 'u1', isSent: false, media: makeMedia());
    when(() => getUnsent()).thenAnswer((_) async => [unsentMessage]);

    final bloc = build();
    bloc.add(LoadChatSocketsEvent());
    await Future<void>.delayed(Duration.zero);

    socket.emitStatus(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(socket.sent.single['message_id'], 'u1');
    expect(socket.sent.single['media'], isA<Map<String, dynamic>>());
    verify(() => deleteUnsent('u1')).called(1);
    await bloc.close();
  });

  test('disconnected status does not trigger a resend', () async {
    final bloc = build();
    bloc.add(LoadChatSocketsEvent());
    await Future<void>.delayed(Duration.zero);

    socket.emitStatus(false);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    verifyNever(() => getUnsent());
    expect(socket.sent, isEmpty);
    await bloc.close();
  });

  test('a failing resend is swallowed and the loop continues', () async {
    when(() => getUnsent()).thenAnswer(
        (_) async => [makeMessage(id: 'u1', isSent: false), makeMessage(id: 'u2', isSent: false)]);
    when(() => deleteUnsent('u1')).thenThrow(Exception('boom'));

    final bloc = build();
    bloc.add(LoadChatSocketsEvent());
    await Future<void>.delayed(Duration.zero);

    socket.emitStatus(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    verify(() => deleteUnsent('u2')).called(1);
    await bloc.close();
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/lobby/presentation/bloc/lobby_bloc.dart';

import '../../../../helpers/fake_socket_services.dart';

void main() {
  late FakeLobbySocketService socket;

  setUp(() => socket = FakeLobbySocketService());

  LobbyBloc build() => LobbyBloc(lobbySocket: socket);

  test('initial state is LobbyBefore8', () {
    expect(build().state, isA<LobbyBefore8>());
  });

  test('ConnectLobbyEvent connects and match-found message emits LobbyMatchFound',
      () async {
    final bloc = build();
    bloc.add(ConnectLobbyEvent());
    await Future<void>.delayed(Duration.zero);
    expect(socket.connectCalled, isTrue);

    socket.emitMessage({
      'type': 'lobby',
      'matched': true,
      'candidate': {
        'id': 4,
        'username': 'carol',
        'profile_picture': {'url': 'c.jpg'},
      },
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final state = bloc.state;
    expect(state, isA<LobbyMatchFound>());
    expect((state as LobbyMatchFound).candidate.username, 'carol');
    await bloc.close();
  });

  test('matched=false emits LobbyNotMatchFound', () async {
    final bloc = build();
    bloc.add(ConnectLobbyEvent());
    await Future<void>.delayed(Duration.zero);

    socket.emitMessage({'type': 'lobby', 'matched': false});
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state, isA<LobbyNotMatchFound>());
    await bloc.close();
  });

  test('event-start and event-end drive LobbyAt8 / LobbyBefore8', () async {
    final bloc = build();
    bloc.add(ConnectLobbyEvent());
    await Future<void>.delayed(Duration.zero);

    socket.emitMessage({'type': 'lobby', 'event': 'event-start'});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<LobbyAt8>());

    socket.emitMessage({'type': 'lobby', 'event': 'event-end'});
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<LobbyBefore8>());
    await bloc.close();
  });

  test('connect failure emits LobbyError', () async {
    socket.connectError = Exception('down');
    final bloc = build();
    bloc.add(ConnectLobbyEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.state, isA<LobbyError>());
    await bloc.close();
  });

  test('DisconnectLobbyEvent disconnects the socket and resets state',
      () async {
    final bloc = build();
    bloc.add(ConnectLobbyEvent());
    await Future<void>.delayed(Duration.zero);

    bloc.add(DisconnectLobbyEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(socket.disconnectCalled, isTrue);
    expect(bloc.state, isA<LobbyBefore8>());
    await bloc.close();
  });
}

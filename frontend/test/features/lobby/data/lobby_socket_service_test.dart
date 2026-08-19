import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/lobby/data/lobby_socket_service.dart';

void main() {
  test('singleton accessor returns the same instance and statics delegate', () {
    final a = LobbySocketService.instance();
    final b = LobbySocketService.instance();
    expect(identical(a, b), isTrue);

    expect(LobbySocketService.lobbyMessageStream, isA<Stream<String>>());
    expect(LobbySocketService.lobbyDisconnectStream, isA<Stream<String?>>());
    expect(a.isConnected, isFalse);
  });
}

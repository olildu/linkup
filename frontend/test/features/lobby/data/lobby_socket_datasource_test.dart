import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/lobby/data/lobby_socket_datasource.dart';

void main() {
  test('singleton accessor returns the same instance and stream delegates', () {
    final a = LobbySocketDatasource.instance();
    final b = LobbySocketDatasource.instance();
    expect(identical(a, b), isTrue);
    expect(LobbySocketDatasource.stream, isA<Stream<String>>());
    expect(a.isConnected, isFalse);
  });
}

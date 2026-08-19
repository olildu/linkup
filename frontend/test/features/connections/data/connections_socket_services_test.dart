import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/data/connections_socket_services.dart';

void main() {
  test('singleton accessor returns the same instance and statics delegate', () {
    final a = ConnectionsSocketService.instance();
    final b = ConnectionsSocketService.instance();
    expect(identical(a, b), isTrue);

    expect(ConnectionsSocketService.connectionsMessageStream,
        isA<Stream<String>>());
    expect(ConnectionsSocketService.connectionsDisconnectStream,
        isA<Stream<String?>>());
    expect(a.isConnected, isFalse);
  });
}

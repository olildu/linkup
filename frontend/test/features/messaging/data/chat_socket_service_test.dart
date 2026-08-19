import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/data/chat_socket_service.dart';

void main() {
  test('singleton accessor returns the same instance and statics delegate', () {
    final a = ChatSocketServices.instance();
    final b = ChatSocketServices.instance();
    expect(identical(a, b), isTrue);

    expect(ChatSocketServices.chatsMessageStream, isA<Stream<String>>());
    expect(ChatSocketServices.chatsDisconnectStream, isA<Stream<String?>>());
    expect(ChatSocketServices.chatsConnectionStatusStream, isA<Stream<bool>>());
    expect(ChatSocketServices.chatsIsConnected, isFalse);
  });
}

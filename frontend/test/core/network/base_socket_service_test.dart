import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/network/base_socket_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../helpers/fake_web_socket_channel.dart';
import '../../helpers/mocks.dart';

class TestSocketService extends BaseSocketService {
  TestSocketService({
    required super.secureStorage,
    required super.connector,
    super.httpClient,
    super.reconnectDelay,
  }) : super(uri: Uri.parse('wss://example.test/ws'), logTag: 'TestSocket');
}

void main() {
  late MockFlutterSecureStorage storage;
  late MockCustomHttpClient httpClient;

  setUp(() {
    storage = MockFlutterSecureStorage();
    httpClient = MockCustomHttpClient();
    when(() => storage.read(key: 'access_token'))
        .thenAnswer((_) async => 'token-1');
  });

  TestSocketService buildService(
    Future<WebSocketChannel> Function(Uri, Map<String, String>) connector, {
    Duration reconnectDelay = const Duration(days: 1),
  }) =>
      TestSocketService(
        secureStorage: storage,
        httpClient: httpClient,
        connector: connector,
        reconnectDelay: reconnectDelay,
      );

  test('aborts connection when no token is stored', () async {
    when(() => storage.read(key: 'access_token'))
        .thenAnswer((_) async => null);
    final service = buildService((_, __) async => FakeWebSocketChannel());

    final disconnects = <String?>[];
    service.disconnectStream.listen(disconnects.add);

    await service.connect();
    await Future<void>.delayed(Duration.zero);

    expect(service.isConnected, isFalse);
    expect(disconnects.single, contains('No token'));
  });

  test('connects with bearer header, forwards messages, sends json frames',
      () async {
    final channel = FakeWebSocketChannel();
    Map<String, String>? seenHeaders;
    final service = buildService((uri, headers) async {
      seenHeaders = headers;
      return channel;
    });

    final messages = <String>[];
    service.messageStream.listen(messages.add);

    await service.connect();
    expect(service.isConnected, isTrue);
    expect(seenHeaders!['Authorization'], 'Bearer token-1');

    channel.incoming.add('{"hello":1}');
    await Future<void>.delayed(Duration.zero);
    expect(messages, ['{"hello":1}']);

    service.sendMessage({'a': 1});
    expect(channel.sentFrames.single, jsonEncode({'a': 1}));

    // Second connect while connected is a no-op.
    await service.connect();
    expect(service.isConnected, isTrue);
  });

  test('manual disconnect closes the channel and does not reconnect',
      () async {
    final channel = FakeWebSocketChannel();
    var connects = 0;
    final service = buildService((_, __) async {
      connects++;
      return channel;
    }, reconnectDelay: const Duration(milliseconds: 10));

    final disconnects = <String?>[];
    service.disconnectStream.listen(disconnects.add);

    await service.connect();
    service.disconnect();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(service.isConnected, isFalse);
    expect(disconnects, contains('Manually disconnected'));
    expect(connects, 1);
  });

  test('remote close schedules a reconnect', () async {
    var connects = 0;
    final channels = <FakeWebSocketChannel>[];
    final service = buildService((_, __) async {
      connects++;
      final c = FakeWebSocketChannel();
      channels.add(c);
      return c;
    }, reconnectDelay: const Duration(milliseconds: 10));

    final disconnects = <String?>[];
    service.disconnectStream.listen(disconnects.add);

    await service.connect();
    await channels.first.incoming.close(); // remote closed
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(connects, greaterThanOrEqualTo(2));
    expect(disconnects.first, contains('Closed'));
    service.disconnect();
  });

  test('stream error triggers reconnect path', () async {
    var connects = 0;
    final service = buildService((_, __) async {
      connects++;
      final c = FakeWebSocketChannel();
      if (connects == 1) {
        scheduleMicrotask(() => c.incoming.addError(StateError('boom')));
      }
      return c;
    }, reconnectDelay: const Duration(milliseconds: 10));

    final disconnects = <String?>[];
    service.disconnectStream.listen(disconnects.add);

    await service.connect();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(disconnects.first, contains('Error'));
    expect(connects, greaterThanOrEqualTo(2));
    service.disconnect();
  });

  test('403 handshake failure refreshes the token before reconnecting',
      () async {
    var connects = 0;
    when(() => httpClient.refreshToken()).thenAnswer((_) async => true);
    final service = buildService((_, __) async {
      connects++;
      if (connects == 1) throw Exception('HTTP 403: Forbidden');
      return FakeWebSocketChannel();
    }, reconnectDelay: const Duration(milliseconds: 10));

    await service.connect();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    verify(() => httpClient.refreshToken()).called(1);
    expect(connects, greaterThanOrEqualTo(2));
    service.disconnect();
  });

  test('failed token refresh is swallowed and reconnect still scheduled',
      () async {
    var connects = 0;
    when(() => httpClient.refreshToken()).thenThrow(Exception('refresh down'));
    final service = buildService((_, __) async {
      connects++;
      if (connects == 1) throw Exception('HTTP 401: Unauthorized');
      return FakeWebSocketChannel();
    }, reconnectDelay: const Duration(milliseconds: 10));

    await service.connect();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(connects, greaterThanOrEqualTo(2));
    service.disconnect();
  });

  test('sendMessage is a no-op when not connected', () {
    final service = buildService((_, __) async => FakeWebSocketChannel());
    service.sendMessage({'a': 1}); // must not throw
    expect(service.isConnected, isFalse);
  });

  test('sink failure during send emits disconnect and schedules reconnect',
      () async {
    var connects = 0;
    late FakeWebSocketChannel channel;
    final service = buildService((_, __) async {
      connects++;
      channel = FakeWebSocketChannel();
      return channel;
    }, reconnectDelay: const Duration(milliseconds: 10));

    final disconnects = <String?>[];
    service.disconnectStream.listen(disconnects.add);

    await service.connect();
    channel.fakeSink.throwOnAdd = true;
    service.sendMessage({'a': 1});
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(disconnects.first, contains('Send failed'));
    expect(connects, greaterThanOrEqualTo(2));
    service.disconnect();
  });

  test('connection status stream emits transitions', () async {
    final channel = FakeWebSocketChannel();
    final service = buildService((_, __) async => channel);

    final statuses = <bool>[];
    service.connectionStatusStream.listen(statuses.add);

    await service.connect();
    channel.incoming.add('x'); // first data triggers status update
    await Future<void>.delayed(Duration.zero);
    service.disconnect();
    await Future<void>.delayed(Duration.zero);

    expect(statuses, containsAllInOrder([true, false]));
  });

  test('dispose disconnects and closes controllers', () async {
    final service = buildService((_, __) async => FakeWebSocketChannel());
    service.dispose();
    expect(service.isConnected, isFalse);
  });
}

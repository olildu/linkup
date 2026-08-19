// StreamController-backed fakes for the socket service singletons. Inject
// into blocs via their optional constructor params; drive incoming traffic
// with [emitMessage]/[emitStatus] and assert outgoing traffic via [sent].
import 'dart:async';
import 'dart:convert';

import 'package:linkup/features/connections/data/connections_socket_services.dart';
import 'package:linkup/features/lobby/data/lobby_socket_service.dart';
import 'package:linkup/features/messaging/data/chat_socket_service.dart';
import 'package:mocktail/mocktail.dart';

mixin _FakeSocketBehaviour {
  final messageController = StreamController<String>.broadcast();
  final disconnectController = StreamController<String?>.broadcast();
  final statusController = StreamController<bool>.broadcast();

  bool connected = true;
  bool connectCalled = false;
  bool disconnectCalled = false;
  Object? connectError;
  final sent = <Map<String, dynamic>>[];

  void emitMessage(Object message) =>
      messageController.add(message is String ? message : jsonEncode(message));

  void emitStatus(bool value) => statusController.add(value);

  Future<void> handleConnect() async {
    connectCalled = true;
    if (connectError != null) throw connectError!;
    connected = true;
  }

  void handleDisconnect() {
    disconnectCalled = true;
    connected = false;
  }
}

class FakeChatSocketServices extends Fake
    with _FakeSocketBehaviour
    implements ChatSocketServices {
  @override
  Stream<String> get messageStream => messageController.stream;
  @override
  Stream<String?> get disconnectStream => disconnectController.stream;
  @override
  Stream<bool> get connectionStatusStream => statusController.stream;
  @override
  bool get isConnected => connected;
  @override
  Future<void> connect({bool isRetry = false}) => handleConnect();
  @override
  void disconnect() => handleDisconnect();
  @override
  void sendMessage(Map<String, dynamic> message) => sent.add(message);
}

class FakeConnectionsSocketService extends Fake
    with _FakeSocketBehaviour
    implements ConnectionsSocketService {
  @override
  Stream<String> get messageStream => messageController.stream;
  @override
  Stream<String?> get disconnectStream => disconnectController.stream;
  @override
  Stream<bool> get connectionStatusStream => statusController.stream;
  @override
  bool get isConnected => connected;
  @override
  Future<void> connect({bool isRetry = false}) => handleConnect();
  @override
  void disconnect() => handleDisconnect();
  @override
  void sendMessage(Map<String, dynamic> message) => sent.add(message);
}

class FakeLobbySocketService extends Fake
    with _FakeSocketBehaviour
    implements LobbySocketService {
  @override
  Stream<String> get messageStream => messageController.stream;
  @override
  Stream<String?> get disconnectStream => disconnectController.stream;
  @override
  Stream<bool> get connectionStatusStream => statusController.stream;
  @override
  bool get isConnected => connected;
  @override
  Future<void> connect({bool isRetry = false}) => handleConnect();
  @override
  void disconnect() => handleDisconnect();
  @override
  void sendMessage(Map<String, dynamic> message) => sent.add(message);
}

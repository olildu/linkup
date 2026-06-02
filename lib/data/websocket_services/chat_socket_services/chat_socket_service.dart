import 'dart:async';
import 'package:linkup/data/websocket_services/base_socket_service.dart';
import 'package:linkup/core/constants/app_constants.dart';

class ChatSocketServices extends BaseSocketService {
  ChatSocketServices() : super(uri: Uri.parse("$WS_BASE_URL/chat"), logTag: 'ChatSocketServices');
  static final ChatSocketServices _instance = ChatSocketServices();

  factory ChatSocketServices.instance() => _instance;

  static Stream<String?> get chatsDisconnectStream => _instance.disconnectStream;
  static Stream<String> get chatsMessageStream => _instance.messageStream;
  static Stream<bool> get chatsConnectionStatusStream => _instance.connectionStatusStream;
  static bool get chatsIsConnected => _instance.isConnected;
}

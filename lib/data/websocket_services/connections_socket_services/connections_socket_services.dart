import 'dart:async';
import 'package:linkup/data/websocket_services/base_socket_service.dart';
import 'package:linkup/core/constants/app_constants.dart';

class ConnectionsSocketService extends BaseSocketService {
  ConnectionsSocketService() : super(uri: Uri.parse("$WS_BASE_URL/connections"), logTag: 'ConnectionsSocketService');
  static final ConnectionsSocketService _instance = ConnectionsSocketService();

  factory ConnectionsSocketService.instance() => _instance;

  static Stream<String> get connectionsMessageStream => _instance.messageStream;
  static Stream<String?> get connectionsDisconnectStream => _instance.disconnectStream;
}

import 'dart:async';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/base_socket_service.dart';

/// Lobby socket. Instance-singleton (same pattern as ChatSocketServices) so
/// blocs can receive a fake instance in tests; the static API is kept for
/// existing callsites and delegates to the singleton.
class LobbySocketService extends BaseSocketService {
  LobbySocketService()
    : super(
        uri: Uri.parse("$WS_BASE_URL/lobby"),
        logTag: 'LobbySocketService',
      );

  static final LobbySocketService _instance = LobbySocketService();

  factory LobbySocketService.instance() => _instance;

  static Stream<String> get lobbyMessageStream => _instance.messageStream;
  static Stream<String?> get lobbyDisconnectStream =>
      _instance.disconnectStream;
}

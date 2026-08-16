import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/data/websocket_services/base_socket_service.dart';

class LobbySocketDatasource extends BaseSocketService {
  static final LobbySocketDatasource _instance = LobbySocketDatasource._();

  factory LobbySocketDatasource.instance() => _instance;

  LobbySocketDatasource._()
    : super(
        uri: Uri.parse('$WS_BASE_URL/lobby'),
        logTag: 'LobbySocketDatasource',
      );

  static Stream<String> get stream => _instance.messageStream;
}

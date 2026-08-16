import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/data/websocket_services/base_socket_service.dart';

class ConnectionsSocketDatasource extends BaseSocketService {
  static final ConnectionsSocketDatasource _instance =
      ConnectionsSocketDatasource._();

  factory ConnectionsSocketDatasource.instance() => _instance;

  ConnectionsSocketDatasource._()
    : super(
        uri: Uri.parse('$WS_BASE_URL/connections'),
        logTag: 'ConnectionsSocketDatasource',
      );

  static Stream<String> get stream => _instance.messageStream;
  static Stream<bool> get statusStream => _instance.connectionStatusStream;
}

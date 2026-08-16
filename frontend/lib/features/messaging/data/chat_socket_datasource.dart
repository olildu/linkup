import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/base_socket_service.dart';

class ChatSocketDatasource extends BaseSocketService {
  static final ChatSocketDatasource _instance = ChatSocketDatasource._();

  factory ChatSocketDatasource.instance() => _instance;

  ChatSocketDatasource._()
    : super(
        uri: Uri.parse('$WS_BASE_URL/chat'),
        logTag: 'ChatSocketDatasource',
      );

  static Stream<String> get stream => _instance.messageStream;
  static Stream<bool> get statusStream => _instance.connectionStatusStream;
  static bool get isSocketConnected => _instance.isConnected;
}

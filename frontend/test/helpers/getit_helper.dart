import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/core/network/custom_http_client.dart';

/// Resets the global GetIt container and registers the fakes that
/// GetIt-reading production code needs (custom_http_client, token_service,
/// chat_page's 'user_id', message_renderer, swipe_wrapper, lookup_picker,
/// connections_bloc, data_parser). Call from setUp; pass only what the code
/// under test resolves.
Future<GetIt> setUpGetIt({
  FlutterSecureStorage? secureStorage,
  CustomHttpClient? httpClient,
  int? userId,
  void Function(GetIt sl)? register,
}) async {
  final sl = GetIt.instance;
  await sl.reset();
  if (secureStorage != null) {
    sl.registerSingleton<FlutterSecureStorage>(secureStorage);
  }
  if (httpClient != null) {
    sl.registerSingleton<CustomHttpClient>(httpClient);
  }
  if (userId != null) {
    sl.registerSingleton<int>(userId, instanceName: 'user_id');
  }
  register?.call(sl);
  return sl;
}

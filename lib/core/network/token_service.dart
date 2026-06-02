import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

class TokenService {
  final FlutterSecureStorage _storage;

  TokenService(this._storage);

  Future<bool> tokenExists() async {
    final access = await _storage.read(key: 'access_token');
    final refresh = await _storage.read(key: 'refresh_token');
    return access != null && refresh != null;
  }

  Future<int?> getSavedUserId() async {
    final str = await _storage.read(key: 'user_id');
    return str != null ? int.tryParse(str) : null;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: '$userId');
    GetIt.instance.isRegistered<int>(instanceName: 'user_id')
        ? GetIt.instance.unregister<int>(instanceName: 'user_id')
        : null;
    GetIt.instance.registerSingleton<int>(userId, instanceName: 'user_id');
  }

  Future<void> registerUserIdIfExists() async {
    final userId = await getSavedUserId();
    if (userId != null) {
      if (GetIt.instance.isRegistered<int>(instanceName: 'user_id')) {
        GetIt.instance.unregister<int>(instanceName: 'user_id');
      }
      GetIt.instance.registerSingleton<int>(userId, instanceName: 'user_id');
    }
  }

  Future<void> clearTokens() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh != null) {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      await _storage.delete(key: 'user_id');
    }
  }
}

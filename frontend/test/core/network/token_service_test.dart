import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/core/network/token_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage storage;
  late TokenService service;

  setUp(() async {
    await GetIt.instance.reset();
    storage = MockFlutterSecureStorage();
    service = TokenService(storage);
  });

  test('tokenExists requires both tokens', () async {
    when(() => storage.read(key: 'access_token'))
        .thenAnswer((_) async => 'a');
    when(() => storage.read(key: 'refresh_token'))
        .thenAnswer((_) async => 'r');
    expect(await service.tokenExists(), isTrue);

    when(() => storage.read(key: 'refresh_token'))
        .thenAnswer((_) async => null);
    expect(await service.tokenExists(), isFalse);
  });

  test('getSavedUserId parses the stored id and handles absence', () async {
    when(() => storage.read(key: 'user_id')).thenAnswer((_) async => '42');
    expect(await service.getSavedUserId(), 42);

    when(() => storage.read(key: 'user_id')).thenAnswer((_) async => null);
    expect(await service.getSavedUserId(), isNull);
  });

  test('saveTokens persists everything and registers user_id in GetIt',
      () async {
    when(() => storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});

    await service.saveTokens(
        accessToken: 'a', refreshToken: 'r', userId: 42);

    verify(() => storage.write(key: 'access_token', value: 'a')).called(1);
    verify(() => storage.write(key: 'refresh_token', value: 'r')).called(1);
    verify(() => storage.write(key: 'user_id', value: '42')).called(1);
    expect(GetIt.instance<int>(instanceName: 'user_id'), 42);

    // Saving again replaces the registration.
    await service.saveTokens(accessToken: 'a', refreshToken: 'r', userId: 7);
    expect(GetIt.instance<int>(instanceName: 'user_id'), 7);
  });

  test('registerUserIdIfExists registers only when an id is stored', () async {
    when(() => storage.read(key: 'user_id')).thenAnswer((_) async => null);
    await service.registerUserIdIfExists();
    expect(GetIt.instance.isRegistered<int>(instanceName: 'user_id'), isFalse);

    when(() => storage.read(key: 'user_id')).thenAnswer((_) async => '42');
    await service.registerUserIdIfExists();
    expect(GetIt.instance<int>(instanceName: 'user_id'), 42);

    // Idempotent when already registered.
    await service.registerUserIdIfExists();
    expect(GetIt.instance<int>(instanceName: 'user_id'), 42);
  });

  test('clearTokens deletes all keys only when a refresh token exists',
      () async {
    when(() => storage.read(key: 'refresh_token'))
        .thenAnswer((_) async => 'r');
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});

    await service.clearTokens();
    verify(() => storage.delete(key: 'access_token')).called(1);
    verify(() => storage.delete(key: 'refresh_token')).called(1);
    verify(() => storage.delete(key: 'user_id')).called(1);

    when(() => storage.read(key: 'refresh_token'))
        .thenAnswer((_) async => null);
    await service.clearTokens();
    verifyNever(() => storage.delete(key: 'access_token'));
  });
}

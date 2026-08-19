import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/settings/data/biometric_lock_service.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  setUpAll(() => registerFallbackValue(const AuthenticationOptions()));

  late MockLocalAuthentication auth;
  late BiometricLockService service;

  setUp(() {
    auth = MockLocalAuthentication();
    service = BiometricLockService(localAuthentication: auth);
  });

  test('isBiometricAvailable is true when either check passes and false on errors',
      () async {
    when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);
    when(() => auth.isDeviceSupported()).thenAnswer((_) async => true);
    expect(await service.isBiometricAvailable(), isTrue);

    when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);
    when(() => auth.isDeviceSupported()).thenAnswer((_) async => false);
    expect(await service.isBiometricAvailable(), isFalse);

    when(() => auth.canCheckBiometrics)
        .thenThrow(PlatformException(code: 'x'));
    expect(await service.isBiometricAvailable(), isFalse);
  });

  test('canUseAppLock also considers enrolled biometrics', () async {
    when(() => auth.canCheckBiometrics).thenAnswer((_) async => false);
    when(() => auth.isDeviceSupported()).thenAnswer((_) async => false);
    when(() => auth.getAvailableBiometrics())
        .thenAnswer((_) async => [BiometricType.face]);
    expect(await service.canUseAppLock(), isTrue);

    when(() => auth.getAvailableBiometrics()).thenAnswer((_) async => []);
    expect(await service.canUseAppLock(), isFalse);

    when(() => auth.canCheckBiometrics)
        .thenThrow(MissingPluginException());
    expect(await service.canUseAppLock(), isFalse);
  });

  test('authenticateForUnlock returns the plugin result and false on errors',
      () async {
    when(() => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenAnswer((_) async => true);
    expect(await service.authenticateForUnlock(), isTrue);

    when(() => auth.authenticate(
          localizedReason: any(named: 'localizedReason'),
          options: any(named: 'options'),
        )).thenThrow(PlatformException(code: 'locked'));
    expect(await service.authenticateForUnlock(), isFalse);
  });
}

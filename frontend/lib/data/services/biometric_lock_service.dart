import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricLockService {
  BiometricLockService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canCheckBiometrics =
          await _localAuthentication.canCheckBiometrics;
      final bool deviceSupported = await _localAuthentication
          .isDeviceSupported();
      return canCheckBiometrics || deviceSupported;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> canUseAppLock() async {
    try {
      final bool canCheckBiometrics =
          await _localAuthentication.canCheckBiometrics;
      final bool deviceSupported = await _localAuthentication
          .isDeviceSupported();
      final List<BiometricType> availableBiometrics = await _localAuthentication
          .getAvailableBiometrics();

      return canCheckBiometrics ||
          deviceSupported ||
          availableBiometrics.isNotEmpty;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> authenticateForUnlock() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Unlock linkup to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

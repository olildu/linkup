import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRemoteDatasource authDs;
  late MockUserRemoteDatasource userDs;
  late MockTokenService tokens;
  late AuthRepositoryImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
    authDs = MockAuthRemoteDatasource();
    userDs = MockUserRemoteDatasource();
    tokens = MockTokenService();
    repo = AuthRepositoryImpl(
      authDatasource: authDs,
      userDatasource: userDs,
      tokenService: tokens,
    );
    when(() => tokens.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
          userId: any(named: 'userId'),
        )).thenAnswer((_) async {});
    when(() => tokens.clearTokens()).thenAnswer((_) async {});
  });

  test('login saves the returned tokens', () async {
    when(() => authDs.login('a@b.com', 'pw')).thenAnswer(
        (_) async => (accessToken: 'at', refreshToken: 'rt', userId: 1));
    await repo.login('a@b.com', 'pw');
    verify(() => tokens.saveTokens(
        accessToken: 'at', refreshToken: 'rt', userId: 1)).called(1);
  });

  test('register saves the returned tokens', () async {
    when(() => authDs.register('hash', 'pw')).thenAnswer(
        (_) async => (accessToken: 'at', refreshToken: 'rt', userId: 2));
    await repo.register('hash', 'pw');
    verify(() => tokens.saveTokens(
        accessToken: 'at', refreshToken: 'rt', userId: 2)).called(1);
  });

  test('resetPassword, sendEmailOTP, verifyEmailOTP, completeProfile delegate',
      () async {
    when(() => authDs.resetPassword('h', 'pw')).thenAnswer((_) async => true);
    await repo.resetPassword('h', 'pw');
    verify(() => authDs.resetPassword('h', 'pw')).called(1);

    when(() => authDs.sendEmailOTP('a@b.com')).thenAnswer((_) async => 200);
    expect(await repo.sendEmailOTP('a@b.com'), 200);

    when(() => authDs.verifyEmailOTP(
            'a@b.com', 1, EmailOTPSubject.emailVerification))
        .thenAnswer((_) async => {'ok': true});
    expect(
        await repo.verifyEmailOTP(
            'a@b.com', 1, EmailOTPSubject.emailVerification),
        {'ok': true});

    final data = UpdateMetadataModel(username: 'u');
    when(() => authDs.completeProfile(data)).thenAnswer((_) async => true);
    expect(await repo.completeProfile(data), isTrue);
  });

  test('logout clears tokens and the app-lock preference', () async {
    await repo.logout();
    verify(() => tokens.clearTokens()).called(1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_lock_enabled'), isNull);
  });

  test('deleteAccount deletes remotely then clears local state', () async {
    when(() => userDs.deleteAccount()).thenAnswer((_) async {});
    await repo.deleteAccount();
    verify(() => userDs.deleteAccount()).called(1);
    verify(() => tokens.clearTokens()).called(1);
  });
}

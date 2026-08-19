import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCustomHttpClient client;

  setUpAll(registerCommonFallbacks);
  setUp(() => client = MockCustomHttpClient());

  AuthRemoteDatasource build(MockClient mock) =>
      AuthRemoteDatasource(client, httpClient: mock);

  group('login', () {
    test('returns tokens on 200', () async {
      final ds = build(MockClient((req) async {
        expect(req.url.path, endsWith('/token'));
        expect(req.bodyFields['username'], 'a@b.com');
        return http.Response(
            jsonEncode({
              'access_token': 'at',
              'refresh_token': 'rt',
              'user_id': 42,
            }),
            200);
      }));
      final result = await ds.login('a@b.com', 'pw');
      expect(result.accessToken, 'at');
      expect(result.refreshToken, 'rt');
      expect(result.userId, 42);
    });

    test('404 throws AccountNotFoundException', () async {
      final ds = build(MockClient((_) async =>
          http.Response(jsonEncode({'detail': 'not found'}), 404)));
      expect(() => ds.login('a@b.com', 'pw'),
          throwsA(isA<AccountNotFoundException>()));
    });

    test('other failures throw a friendly ApiException', () async {
      final ds = build(MockClient((_) async =>
          http.Response(jsonEncode({'detail': 'bad creds'}), 401)));
      expect(
          () => ds.login('a@b.com', 'pw'),
          throwsA(isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)));
    });
  });

  group('sendEmailOTP', () {
    test('returns the status code and 500 on network failure', () async {
      final ok = build(MockClient((_) async => http.Response('{}', 200)));
      expect(await ok.sendEmailOTP('a@b.com'), 200);

      final broken =
          build(MockClient((_) async => throw Exception('offline')));
      expect(await broken.sendEmailOTP('a@b.com'), 500);
    });
  });

  group('verifyEmailOTP', () {
    test('returns the body on 200 and sends the subject value', () async {
      final ds = build(MockClient((req) async {
        expect(jsonDecode(req.body)['subject'], 'email_verification');
        return http.Response(jsonEncode({'email_hash': 'h'}), 200);
      }));
      final result = await ds.verifyEmailOTP(
          'a@b.com', 111111, EmailOTPSubject.emailVerification);
      expect(result['email_hash'], 'h');
    });

    test('throws on failure', () async {
      final ds = build(MockClient((_) async =>
          http.Response(jsonEncode({'detail': 'wrong otp'}), 400)));
      expect(
          () =>
              ds.verifyEmailOTP('a@b.com', 1, EmailOTPSubject.forgotPassword),
          throwsA(isA<ApiException>()));
    });
  });

  group('register', () {
    test('returns tokens when the backend reports success', () async {
      final ds = build(MockClient((_) async => http.Response(
          jsonEncode({
            'status': 'success',
            'access_token': 'at',
            'refresh_token': 'rt',
            'user_id': 7,
          }),
          201)));
      final result = await ds.register('hash', 'pw');
      expect(result.userId, 7);
    });

    test('throws when the status is not success or code is bad', () async {
      final noSuccess = build(MockClient(
          (_) async => http.Response(jsonEncode({'status': 'nope'}), 200)));
      expect(() => noSuccess.register('hash', 'pw'),
          throwsA(isA<ApiException>()));

      final badCode = build(MockClient((_) async =>
          http.Response(jsonEncode({'detail': 'duplicate'}), 409)));
      expect(() => badCode.register('hash', 'pw'),
          throwsA(isA<ApiException>()));
    });
  });

  group('resetPassword', () {
    test('returns true on success and throws on failure', () async {
      final ok = build(MockClient((_) async =>
          http.Response(jsonEncode({'status': 'success'}), 200)));
      expect(await ok.resetPassword('hash', 'pw'), isTrue);

      final bad = build(
          MockClient((_) async => http.Response(jsonEncode({}), 500)));
      expect(() => bad.resetPassword('hash', 'pw'),
          throwsA(isA<ApiException>()));
    });
  });

  test('completeProfile posts via CustomHttpClient and checks the msg field',
      () async {
    when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(jsonEncode({'msg': 'created'}), 200));

    final ds = build(MockClient((_) async => http.Response('{}', 200)));
    expect(await ds.completeProfile(UpdateMetadataModel(username: 'u')),
        isTrue);

    when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(jsonEncode({'other': 1}), 200));
    expect(await ds.completeProfile(UpdateMetadataModel(username: 'u')),
        isFalse);
  });
}

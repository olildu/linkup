import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/profile/data/models/user_preference_model.dart';
import 'package:linkup/features/profile/data/user_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockCustomHttpClient client;
  late UserRemoteDatasource ds;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    client = MockCustomHttpClient();
    ds = UserRemoteDatasource(client);
  });

  test('getProfile parses UserModel and throws on failure', () async {
    when(() => client.get(any())).thenAnswer((_) async => http.Response(
        jsonEncode({'id': 1, 'university_id': 2, 'username': 'me'}), 200));
    final user = await ds.getProfile();
    expect(user.id, 1);
    expect(user.username, 'me');

    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getProfile(), throwsException);
  });

  test('getOtherProfile hits the detail path and parses the candidate',
      () async {
    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/user/get/detail/7'));
      return http.Response(
          jsonEncode({
            'id': 7,
            'username': 'alice',
            'gender': 'Female',
            'university_id': 1,
            'profile_picture': {},
            'dob': '2000-05-20T00:00:00.000',
            'university_major': 'CS',
            'university_year': 3,
            'photos': [],
            'about': '',
            'currently_staying': '',
            'hometown': '',
          }),
          200);
    });
    expect((await ds.getOtherProfile(7)).username, 'alice');

    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 404));
    expect(() => ds.getOtherProfile(7), throwsException);
  });

  test('updateProfile posts metadata with the update_pfp flag', () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.queryParameters['update_pfp'], 'true');
      return http.Response('{}', 200);
    });
    await ds.updateProfile(UpdateMetadataModel(about: 'x'), updatePfp: true);

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.updateProfile(UpdateMetadataModel(about: 'x')),
        throwsException);
  });

  test('getPreference and updatePreference round-trip', () async {
    when(() => client.get(any())).thenAnswer((_) async =>
        http.Response(jsonEncode({'interested_gender': 'female'}), 200));
    expect((await ds.getPreference()).interestedGender, 'female');

    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getPreference(), throwsException);

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 200));
    await ds.updatePreference(UserPreferenceModel(height: 170));

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.updatePreference(UserPreferenceModel(height: 170)),
        throwsException);
  });

  test('deleteAccount, blockUser and reportUser check the status code',
      () async {
    when(() => client.delete(any()))
        .thenAnswer((_) async => http.Response('{}', 200));
    await ds.deleteAccount();
    when(() => client.delete(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.deleteAccount(), throwsException);

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final body = jsonDecode(invocation.namedArguments[#body]);
      if (body.containsKey('blocked_user_id')) {
        expect(body['blocked_user_id'], 9);
      } else {
        expect(body['reported_user_id'], 9);
        expect(body['reason'], 'spam');
      }
      return http.Response('{}', 200);
    });
    await ds.blockUser(9);
    await ds.reportUser(9, 'spam');

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.blockUser(9), throwsException);
    expect(() => ds.reportUser(9, 'spam'), throwsException);
  });
}

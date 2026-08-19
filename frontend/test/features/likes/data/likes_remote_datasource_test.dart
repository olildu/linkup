import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/features/likes/data/likes_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockCustomHttpClient client;
  late LikesRemoteDatasource ds;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    client = MockCustomHttpClient();
    ds = LikesRemoteDatasource(client);
  });

  test('getReceivedLikes parses the response and passes the offset', () async {
    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.queryParameters['offset'], '20');
      return http.Response(
          jsonEncode({
            'entries': [
              {'id': 1, 'revealed': false}
            ],
            'total_count': 3,
            'unseen_count': 1,
          }),
          200);
    });

    final result = await ds.getReceivedLikes(offset: 20);
    expect(result.entries.single.id, 1);
    expect(result.totalCount, 3);
  });

  test('getReceivedLikes throws on failure', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getReceivedLikes(), throwsException);
  });

  test('getLikesCount parses total_count and throws on failure', () async {
    when(() => client.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode({'total_count': 9}), 200));
    expect(await ds.getLikesCount(), 9);

    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getLikesCount(), throwsException);
  });

  test('likeBack posts to the right path and returns the body', () async {
    when(() => client.post(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/likes/5/like-back'));
      return http.Response(jsonEncode({'match': true}), 200);
    });
    expect(await ds.likeBack(5), {'match': true});

    when(() => client.post(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.likeBack(5), throwsException);
  });

  test('passLike posts and throws on failure', () async {
    when(() => client.post(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/likes/5/pass'));
      return http.Response('{}', 200);
    });
    await ds.passLike(5);

    when(() => client.post(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.passLike(5), throwsException);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/features/discovery/data/match_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

Map<String, dynamic> candidateJson(int id) => {
      'id': id,
      'username': 'u$id',
      'gender': 'Female',
      'university_id': 1,
      'profile_picture': {'url': 'p.jpg'},
      'dob': '2000-05-20T00:00:00.000',
      'university_major': 'CS',
      'university_year': 3,
      'photos': [],
      'about': 'hi',
      'currently_staying': 'PG',
      'hometown': 'Home',
    };

void main() {
  late MockCustomHttpClient client;
  late MatchRemoteDatasource ds;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    client = MockCustomHttpClient();
    ds = MatchRemoteDatasource(client);
  });

  test('getMatchUsers parses matches and adds refresh query param', () async {
    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.queryParameters['refresh'], 'true');
      return http.Response(
          jsonEncode({
            'matches': [candidateJson(1)],
            'swipes_remaining': 4,
          }),
          200);
    });

    final result = await ds.getMatchUsers(refresh: true);
    expect(result.matches.single.id, 1);
    expect(result.swipesRemaining, 4);
  });

  test('getMatchUsers throws on failure', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getMatchUsers(), throwsException);
  });

  test('getConnections parses matches and chats', () async {
    when(() => client.get(any())).thenAnswer((_) async => http.Response(
        jsonEncode({
          'matches': [
            {'id': 4, 'username': 'c', 'profile_picture': {}},
          ],
          'chats': [
            {
              'id': 3,
              'username': 'b',
              'profile_picture': {},
              'chat_room_id': 10,
              'unseen_counter': 0,
            },
          ],
        }),
        200));

    final result = await ds.getConnections();
    expect(result.matches.single.id, 4);
    expect(result.chats.single.chatRoomId, 10);
  });

  test('getConnections throws on failure', () async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.getConnections(), throwsException);
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/features/messaging/data/chat_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

Map<String, dynamic> messageJson(String id) => {
      'message_id': id,
      'message': 'hi',
      'to': 2,
      'from_': 1,
      'chat_room_id': 10,
      'timestamp': '2026-01-01T12:00:00.000',
    };

void main() {
  late MockCustomHttpClient client;
  late ChatRemoteDatasource ds;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    client = MockCustomHttpClient();
    ds = ChatRemoteDatasource(client);
  });

  test('startChat posts the user id and returns the body', () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      expect(jsonDecode(invocation.namedArguments[#body])['id'], 2);
      return http.Response(jsonEncode({'chat_room_id': 10}), 200);
    });
    expect(await ds.startChat(2), {'chat_room_id': 10});

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.startChat(2), throwsException);
  });

  test('fetchMessages parses the message list', () async {
    when(() => client.post(any(), body: any(named: 'body'))).thenAnswer(
        (_) async => http.Response(
            jsonEncode({'messages': [messageJson('m1')]}), 200));
    final messages = await ds.fetchMessages(10);
    expect(messages.single.id, 'm1');

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.fetchMessages(10), throwsException);
  });

  test('fetchPaginatedMessages sends the cursor fields', () async {
    final ts = DateTime(2026, 1, 1);
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final body = jsonDecode(invocation.namedArguments[#body]);
      expect(body['last_message_id'], 'm1');
      expect(body['last_message_timestamp'], ts.toIso8601String());
      return http.Response(
          jsonEncode({'messages': [messageJson('m0')]}), 200);
    });

    final messages = await ds.fetchPaginatedMessages(
        chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts);
    expect(messages.single.id, 'm0');

    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(
        () => ds.fetchPaginatedMessages(
            chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts),
        throwsException);
  });
}

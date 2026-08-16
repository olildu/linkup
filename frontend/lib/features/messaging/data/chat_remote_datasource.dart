import 'dart:convert';
import 'dart:developer';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';

class ChatRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'ChatRemoteDatasource';

  ChatRemoteDatasource(this._client);

  Future<Map<String, dynamic>> startChat(int chatUserId) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/chats/start-chat'),
      body: jsonEncode({'id': chatUserId}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    log('startChat error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to start chat: ${response.statusCode}');
  }

  Future<List<Message>> fetchMessages(int chatRoomId) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/chats/get/chat'),
      body: jsonEncode({'chat_room_id': chatRoomId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
    }
    log('fetchMessages error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to fetch messages: ${response.statusCode}');
  }

  Future<List<Message>> fetchPaginatedMessages({
    required int chatRoomId,
    required String lastMessageId,
    required DateTime lastMessageTimeStamp,
  }) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/chats/get/chat-paginated'),
      body: jsonEncode({
        'chat_room_id': chatRoomId,
        'last_message_id': lastMessageId,
        'last_message_timestamp': lastMessageTimeStamp.toIso8601String(),
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['messages'] as List)
          .map((m) => Message.fromJson(m))
          .toList();
    }
    log('fetchPaginatedMessages error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to paginate messages: ${response.statusCode}');
  }
}

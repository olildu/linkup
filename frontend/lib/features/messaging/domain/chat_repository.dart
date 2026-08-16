import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/domain/message_entity.dart';

abstract class ChatRepository {
  Future<Map<String, dynamic>> startChat(int chatUserId);
  Future<List<MessageEntity>> fetchMessages(int chatRoomId);
  Future<List<MessageEntity>> fetchPaginatedMessages({
    required int chatRoomId,
    required String lastMessageId,
    required DateTime lastMessageTimeStamp,
  });
  Future<List<MessageEntity>> getCachedMessages(int chatRoomId);
  Future<void> cacheMessage(MessageEntity message, int maxCount);
  Future<void> saveUnsentMessage(MessageEntity message);
  Future<List<MessageEntity>> getUnsentMessages();
  Future<void> deleteUnsentMessage(int isarId);
  Future<void> deleteUnsentMessageByMsgId(String messageId);
  Future<Map<String, dynamic>> uploadChatMedia(
    File file,
    MessageType mediaType,
  );
}

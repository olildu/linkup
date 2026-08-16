import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/data/datasources/local/message_local_datasource.dart';
import 'package:linkup/data/datasources/remote/chat_remote_datasource.dart';
import 'package:linkup/data/datasources/remote/media_remote_datasource.dart';
import 'package:linkup/data/models/chat_models/media_message_data_model.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/domain/entities/media_message_entity.dart';
import 'package:linkup/domain/entities/message_entity.dart';
import 'package:linkup/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _chatDatasource;
  final MediaRemoteDatasource _mediaDatasource;
  final MessageLocalDatasource _localDatasource;

  const ChatRepositoryImpl({
    required ChatRemoteDatasource chatDatasource,
    required MediaRemoteDatasource mediaDatasource,
    required MessageLocalDatasource localDatasource,
  }) : _chatDatasource = chatDatasource,
       _mediaDatasource = mediaDatasource,
       _localDatasource = localDatasource;

  @override
  Future<Map<String, dynamic>> startChat(int chatUserId) =>
      _chatDatasource.startChat(chatUserId);

  @override
  Future<List<MessageEntity>> fetchMessages(int chatRoomId) async {
    final models = await _chatDatasource.fetchMessages(chatRoomId);
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<MessageEntity>> fetchPaginatedMessages({
    required int chatRoomId,
    required String lastMessageId,
    required DateTime lastMessageTimeStamp,
  }) async {
    final models = await _chatDatasource.fetchPaginatedMessages(
      chatRoomId: chatRoomId,
      lastMessageId: lastMessageId,
      lastMessageTimeStamp: lastMessageTimeStamp,
    );
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<MessageEntity>> getCachedMessages(int chatRoomId) async {
    final models = await _localDatasource.getMessages(chatRoomId);
    return models.map(_toEntity).toList();
  }

  @override
  Future<void> cacheMessage(MessageEntity entity, int maxCount) =>
      _localDatasource.cacheMessage(_fromEntity(entity), maxCount);

  @override
  Future<void> saveUnsentMessage(MessageEntity entity) =>
      _localDatasource.saveUnsent(_fromEntity(entity));

  @override
  Future<List<MessageEntity>> getUnsentMessages() async {
    final rows = await _localDatasource.getAllUnsent();
    return rows.map((r) => _toEntity(r.toMessage())).toList();
  }

  @override
  Future<void> deleteUnsentMessage(int isarId) =>
      _localDatasource.deleteUnsent(isarId);

  @override
  Future<void> deleteUnsentMessageByMsgId(String messageId) =>
      _localDatasource.deleteUnsentByMessageId(messageId);

  @override
  Future<Map<String, dynamic>> uploadChatMedia(
    File file,
    MessageType mediaType,
  ) => _mediaDatasource.uploadChatMedia(file, mediaType);

  MessageEntity _toEntity(Message m) => MessageEntity(
    id: m.id,
    message: m.message,
    replyID: m.replyID,
    to: m.to,
    from_: m.from_,
    chatRoomId: m.chatRoomId,
    isSeen: m.isSeen,
    isSent: m.isSent,
    timestamp: m.timestamp,
    media: m.media == null
        ? null
        : MediaMessageEntity(
            fileKey: m.media!.fileKey,
            mediaType: m.media!.mediaType,
            blurhashText: m.media!.blurhashText,
            metadata: m.media!.metadata,
          ),
  );

  Message _fromEntity(MessageEntity e) => Message(
    id: e.id,
    message: e.message,
    replyID: e.replyID,
    to: e.to,
    from_: e.from_,
    chatRoomId: e.chatRoomId,
    isSeen: e.isSeen,
    isSent: e.isSent,
    timestamp: e.timestamp,
    media: e.media == null
        ? null
        : MediaMessageData(
            fileKey: e.media!.fileKey,
            mediaType: e.media!.mediaType,
            blurhashText: e.media!.blurhashText,
            metadata: e.media!.metadata,
          ),
  );
}

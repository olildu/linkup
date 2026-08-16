import 'package:linkup/features/messaging/domain/media_message_entity.dart';

class MessageEntity {
  final String id;
  final String message;
  final String? replyID;
  final int to;
  final int from_;
  final int chatRoomId;
  final bool isSeen;
  final bool isSent;
  final DateTime timestamp;
  final MediaMessageEntity? media;

  const MessageEntity({
    required this.id,
    required this.message,
    required this.to,
    required this.from_,
    required this.chatRoomId,
    required this.timestamp,
    this.replyID,
    this.isSeen = false,
    this.isSent = true,
    this.media,
  });

  MessageEntity copyWith({
    String? id,
    String? message,
    String? replyID,
    int? to,
    int? from_,
    int? chatRoomId,
    bool? isSeen,
    bool? isSent,
    DateTime? timestamp,
    MediaMessageEntity? media,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      message: message ?? this.message,
      replyID: replyID ?? this.replyID,
      to: to ?? this.to,
      from_: from_ ?? this.from_,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isSeen: isSeen ?? this.isSeen,
      isSent: isSent ?? this.isSent,
      timestamp: timestamp ?? this.timestamp,
      media: media ?? this.media,
    );
  }
}

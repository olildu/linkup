import 'package:linkup/features/messaging/data/models/media_message_data_model.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String id;
  final String message;
  final String? replyID;

  final int to;
  final int from_;

  final int chatRoomId;
  final bool isSeen;
  final bool isSent;

  final DateTime timestamp;
  final MediaMessageData? media;

  Message({
    required this.message,
    required this.to,
    required this.timestamp,
    required this.from_,
    required this.chatRoomId,
    required this.id,
    this.isSeen = false,
    this.isSent = true,
    this.media,
    this.replyID,
  });

  Message copyWith({
    String? id,
    String? message,
    String? replyID,
    int? chatRoomId,
    int? to,
    int? from_,
    bool? isSeen,
    bool? isSent,
    MediaMessageData? media,
    DateTime? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      replyID: replyID ?? this.replyID,
      message: message ?? this.message,
      to: to ?? this.to,
      from_: from_ ?? this.from_,
      timestamp: timestamp ?? this.timestamp,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      isSeen: isSeen ?? this.isSeen,
      isSent: isSent ?? this.isSent,
      media: media ?? this.media,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: (json['message_id'] ?? Uuid().v4()) as String,
      message: json['message'] as String,
      to: json['to'] as int,
      from_: json['from_'] as int,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      chatRoomId: json['chat_room_id'] as int,
      isSeen: (json['is_seen'] ?? false) as bool,
      isSent: (json['is_sent'] ?? true) as bool,
      media: json['media'] != null
          ? MediaMessageData.fromJson(json['media'] as Map<String, dynamic>)
          : null,
      replyID: json['reply_id'] != null ? (json['reply_id'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message_id": id,
      "type": "chats",
      "chats_type": "message",
      "message": message,
      "to": to,
      "from_": from_,
      "chat_room_id": chatRoomId,
      "is_sent": isSent,
      if (media != null) "media": media!.toJson(),
      if (replyID != null) "reply_id": replyID,
    };
  }
}

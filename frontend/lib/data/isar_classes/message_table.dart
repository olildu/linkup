import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:linkup/data/models/chat_models/media_message_data_model.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';

part 'message_table.g.dart';

@collection
class MessageTable {
  Id id = Isar.autoIncrement;

  late String messageID; // your UUID

  late String message;

  late int to;
  late int from_;

  late int chatRoomId;
  late bool isSeen;
  late bool isSent;

  late DateTime timestamp;

  String? mediaJson;

  MessageTable();

  MessageTable.fromMessage(Message msg) {
    messageID = msg.id;
    message = msg.message;
    to = msg.to;
    from_ = msg.from_;
    chatRoomId = msg.chatRoomId;
    isSeen = msg.isSeen;
    isSent = msg.isSent;
    timestamp = msg.timestamp;
    mediaJson = msg.media != null ? jsonEncode(msg.media!.toJson()) : null;
  }

  Message toMessage() {
    return Message(
      id: messageID,
      message: message,
      to: to,
      from_: from_,
      chatRoomId: chatRoomId,
      isSeen: isSeen,
      isSent: isSent,
      timestamp: timestamp,
      media: mediaJson != null
          ? MediaMessageData.fromJson(jsonDecode(mediaJson!))
          : null,
    );
  }
}

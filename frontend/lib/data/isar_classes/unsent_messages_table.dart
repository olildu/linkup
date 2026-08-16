import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';

part 'unsent_messages_table.g.dart';

@collection
class UnsentMessagesTable {
  Id id = Isar.autoIncrement;

  late String messageID;
  late int chatRoomID;
  late String message;
  UnsentMessagesTable();

  UnsentMessagesTable.fromMessage(Message msg) {
    messageID = msg.id;
    message = jsonEncode(msg.toJson());
    chatRoomID = msg.chatRoomId;
  }

  Message toMessage() {
    return Message.fromJson(jsonDecode(message));
  }
}

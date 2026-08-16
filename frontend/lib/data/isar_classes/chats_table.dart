import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:linkup/data/models/chats_connection_model.dart';

part 'chats_table.g.dart';

@collection
class ChatsTable {
  Id id = Isar.autoIncrement;

  late int chatID;
  late String username;
  String? profilePictureMetaDataJson;
  late int chatRoomId;
  late int unseenCounter;
  late String? message;
  bool isDeleted = false; // <--- 1. ADD NEW FIELD HERE

  ChatsTable();

  ChatsTable.fromChat(ChatsConnectionModel chatsConnectionModel) {
    chatID = chatsConnectionModel.id;
    username = chatsConnectionModel.username;
    // Handle null profile picture
    profilePictureMetaDataJson = jsonEncode(
      chatsConnectionModel.profilePictureMetaData,
    );
    chatRoomId = chatsConnectionModel.chatRoomId;
    unseenCounter = chatsConnectionModel.unseenCounter;
    message = chatsConnectionModel.message;
    isDeleted = chatsConnectionModel.isDeleted;
  }

  ChatsConnectionModel toChatsConnectionModel() {
    return ChatsConnectionModel(
      id: chatID,
      username: username,
      profilePictureMetaData: profilePictureMetaDataJson != null
          ? jsonDecode(profilePictureMetaDataJson!)
          : null,
      chatRoomId: chatRoomId,
      unseenCounter: unseenCounter,
      message: message,
      isDeleted: isDeleted,
    );
  }
}

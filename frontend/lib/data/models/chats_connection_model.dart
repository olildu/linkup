import 'package:linkup/data/enums/message_type_enum.dart';

class ChatsConnectionModel {
  final int id;
  final String username;
  final Map profilePictureMetaData;
  final int chatRoomId;
  final int unseenCounter;
  final String? message;
  final MessageType messageType;
  final bool isDeleted;

  ChatsConnectionModel({
    required this.id,
    required this.username,
    required this.profilePictureMetaData,
    required this.chatRoomId,
    required this.unseenCounter,
    this.message,
    this.messageType = MessageType.text,
    this.isDeleted = false,
  });

  factory ChatsConnectionModel.fromJson(Map<String, dynamic> json) {
    return ChatsConnectionModel(
      id: json['id'],
      username: json['username'],
      profilePictureMetaData: json['profile_picture'],
      chatRoomId: json['chat_room_id'],
      unseenCounter: json['unseen_counter'],
      message: json['last_message'],
      messageType: messageTypeFromString(json['last_message_media_type']),
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  ChatsConnectionModel copyWith({
    int? id,
    String? username,
    Map? profilePictureMetaData,
    int? chatRoomId,
    int? unseenCounter,
    String? message,
    MessageType? messageType,
  }) {
    return ChatsConnectionModel(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePictureMetaData:
          profilePictureMetaData ?? this.profilePictureMetaData,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      unseenCounter: unseenCounter ?? this.unseenCounter,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
    );
  }
}

import 'package:linkup/core/enums/message_type_enum.dart';

class ChatConnectionEntity {
  final int id;
  final String username;
  final Map profilePictureMetaData;
  final int chatRoomId;
  final int unseenCounter;
  final String? message;
  final MessageType messageType;
  final bool isDeleted;

  const ChatConnectionEntity({
    required this.id,
    required this.username,
    required this.profilePictureMetaData,
    required this.chatRoomId,
    required this.unseenCounter,
    this.message,
    this.messageType = MessageType.text,
    this.isDeleted = false,
  });

  ChatConnectionEntity copyWith({
    int? id,
    String? username,
    Map? profilePictureMetaData,
    int? chatRoomId,
    int? unseenCounter,
    String? message,
    MessageType? messageType,
    bool? isDeleted,
  }) {
    return ChatConnectionEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      profilePictureMetaData:
          profilePictureMetaData ?? this.profilePictureMetaData,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      unseenCounter: unseenCounter ?? this.unseenCounter,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

import 'package:linkup/data/enums/message_type_enum.dart';

class LiveChatDataModel {
  final int from_;
  final int chatRoomId;
  final int unseenCounterIncBy;
  final MessageType messageType;
  final String? message;
  final bool changeOrder;

  LiveChatDataModel({
    required this.unseenCounterIncBy,
    required this.from_,
    required this.chatRoomId,
    required this.messageType,
    this.message,
    this.changeOrder = false,
  });
}

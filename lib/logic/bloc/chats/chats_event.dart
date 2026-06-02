part of 'chats_bloc.dart';

@immutable
sealed class ChatsEvent {}

final class LoadChatsEvent extends ChatsEvent {}

final class NewMessageEvent extends ChatsEvent {
  final Map<String, dynamic> message;
  NewMessageEvent(this.message);
}

final class TypingEvent extends ChatsEvent {
  final Map<String, dynamic> message;
  TypingEvent(this.message);
}

final class SendTypingEvent extends ChatsEvent {
  final int currentChatUserId;
  SendTypingEvent({required this.currentChatUserId});
}

final class TypingTimeoutEvent extends ChatsEvent {
  final int userId;
  TypingTimeoutEvent({required this.userId});
}

final class SendMessageEvent extends ChatsEvent {
  final Message message;
  SendMessageEvent({required this.message});
}

class StartChatsEvent extends ChatsEvent {
  final bool showLoading;
  StartChatsEvent({this.showLoading = false});
}

class MarkMessageAsSeenEvent extends ChatsEvent {
  final String messageId;
  MarkMessageAsSeenEvent({required this.messageId});
}

final class SeenEvent extends ChatsEvent {
  final Map<String, dynamic> message;
  SeenEvent(this.message);
}

final class UploadMediaChatEvent extends ChatsEvent {
  final File file;
  final MessageType mediaType;
  final String? description;

  UploadMediaChatEvent({required this.file, required this.mediaType, this.description});
}

final class PaginateAddMessagesEvent extends ChatsEvent {
  final int chatRoomId;
  final String lastMessageID;
  final DateTime lastMessageTimeStamp;

  PaginateAddMessagesEvent({required this.chatRoomId, required this.lastMessageID, required this.lastMessageTimeStamp});
}

final class _ClearSocketDisconnectedFlagEvent extends ChatsEvent {
  final Message message;

  _ClearSocketDisconnectedFlagEvent({required this.message});
}

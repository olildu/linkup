part of 'chats_bloc.dart';

@immutable
sealed class ChatsState {}

final class ChatsInitial extends ChatsState {}

final class ChatsLoading extends ChatsState {}

final class ChatsLoaded extends ChatsState {
  final List<Message> messages;
  final bool isTyping;
  final bool otherUserSeenMsg;
  final int? typingUserId;
  final bool isFetchingPaginatedMessages;
  final bool isSocketConnected;

  ChatsLoaded({
    required this.messages,
    this.isTyping = false,
    this.otherUserSeenMsg = false,
    this.typingUserId,
    this.isFetchingPaginatedMessages = false,
    this.isSocketConnected = false,
  });

  ChatsLoaded copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? otherUserSeenMsg,
    int? typingUserId,
    bool? isSocketConnected,
    bool? isFetchingPaginatedMessages,
  }) {
    return ChatsLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      otherUserSeenMsg: otherUserSeenMsg ?? this.otherUserSeenMsg,
      typingUserId: typingUserId ?? this.typingUserId,
      isFetchingPaginatedMessages:
          isFetchingPaginatedMessages ?? this.isFetchingPaginatedMessages,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
    );
  }
}

final class ChatsError extends ChatsState {}

final class ChatsEmpty extends ChatsState {}

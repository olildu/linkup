part of 'connections_bloc.dart';

@immutable
sealed class ConnectionsEvent {}

class LoadConnectionsEvent extends ConnectionsEvent {
  final bool showLoading;

  LoadConnectionsEvent({this.showLoading = false});
}

class ReloadChatConnectionsEvent extends ConnectionsEvent {
  final LiveChatDataModel? liveChatData;

  ReloadChatConnectionsEvent({this.liveChatData});
}

class MarkMessagesSeenEvent extends ConnectionsEvent {
  final int chatRoomId;
  final int decrementCounterTo;

  MarkMessagesSeenEvent({
    required this.chatRoomId,
    this.decrementCounterTo = 0,
  });
}

class BlockUserEvent extends ConnectionsEvent {
  final int userIdToBlock;
  final int? chatRoomId;

  BlockUserEvent({required this.userIdToBlock, this.chatRoomId});
}

class ReportUserEvent extends ConnectionsEvent {
  final int userIdToReport;
  final String reason;

  ReportUserEvent({required this.userIdToReport, required this.reason});
}

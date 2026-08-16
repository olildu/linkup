part of 'chat_sockets_bloc.dart';

@immutable
sealed class ChatSocketsEvent {}

final class LoadChatSocketsEvent extends ChatSocketsEvent {}

final class ReconnectChatSocketsEvent extends ChatSocketsEvent {}

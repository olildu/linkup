part of 'chat_sockets_bloc.dart';

@immutable
sealed class ChatSocketsState {}

final class ChatSocketsInitial extends ChatSocketsState {}

final class ChatSocketsConnecting extends ChatSocketsState {}

final class ChatSocketsError extends ChatSocketsState {}

final class ChatSocketsConnected extends ChatSocketsState {}

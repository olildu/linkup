part of 'web_socket_bloc.dart';

@immutable
sealed class WebSocketState {}

final class WebSocketInitial extends WebSocketState {}

final class WebSocketConnecting extends WebSocketState {}

final class WebSocketError extends WebSocketState {}

final class WebSocketConnected extends WebSocketState {}

part of 'web_socket_bloc.dart';

@immutable
sealed class WebSocketEvent {}

final class LoadWebSockEvent extends WebSocketEvent {}

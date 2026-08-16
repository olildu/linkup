part of 'connections_socket_bloc.dart';

@immutable
sealed class ConnectionsSocketEvent {}

final class LoadConnectionSocketsEvent extends ConnectionsSocketEvent {}

final class ReconnectConnectionSocketsEvent extends ConnectionsSocketEvent {}

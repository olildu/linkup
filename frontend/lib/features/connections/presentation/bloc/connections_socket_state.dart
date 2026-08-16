part of 'connections_socket_bloc.dart';

@immutable
sealed class ConnectionsSocketState {}

final class ConnectionsSocketInitial extends ConnectionsSocketState {}

final class ConnectionsSocketsConnected extends ConnectionsSocketState {}

final class ConnectionsSocketsConnecting extends ConnectionsSocketState {}

final class ConnectionsSocketsError extends ConnectionsSocketState {}

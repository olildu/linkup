part of 'connections_bloc.dart';

@immutable
sealed class ConnectionsState {}

final class ConnectionsInitial extends ConnectionsState {}

final class ConnectionsLoading extends ConnectionsState {}

final class ConnectionsError extends ConnectionsState {}

final class ConnectionsLoaded extends ConnectionsState {
  final List<ChatConnectionEntity> chats;
  final List<MatchesConnectionEntity> matches;

  ConnectionsLoaded({required this.chats, required this.matches});

  ConnectionsLoaded copyWith({
    List<ChatConnectionEntity>? chats,
    List<MatchesConnectionEntity>? matches,
  }) {
    return ConnectionsLoaded(
      chats: chats ?? this.chats,
      matches: matches ?? this.matches,
    );
  }
}

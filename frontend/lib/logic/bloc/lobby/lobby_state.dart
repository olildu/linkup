part of 'lobby_bloc.dart';

@immutable
sealed class LobbyState {}

final class LobbyBefore8 extends LobbyState {}

final class LobbyAt8 extends LobbyState {}

final class LobbyAfter8Waiting extends LobbyState {}

final class LobbyMatchFound extends LobbyState {
  final MatchesConnectionEntity candidate;
  LobbyMatchFound({required this.candidate});
}

final class LobbyNotMatchFound extends LobbyState {}

final class LobbyError extends LobbyState {}

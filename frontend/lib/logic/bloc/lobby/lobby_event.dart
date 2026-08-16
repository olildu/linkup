part of 'lobby_bloc.dart';

@immutable
sealed class LobbyEvent {}

class ConnectLobbyEvent extends LobbyEvent {}

class DisconnectLobbyEvent extends LobbyEvent {}

class LobbyMatchFoundEvent extends LobbyEvent {
  final MatchesConnectionEntity candidate;
  LobbyMatchFoundEvent({required this.candidate});
}

class LobbyMatchNotFoundEvent extends LobbyEvent {}

class StartLobbyEvent extends LobbyEvent {}

class EndLobbyEvent extends LobbyEvent {}

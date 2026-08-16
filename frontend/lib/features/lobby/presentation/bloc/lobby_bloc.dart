import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/features/discovery/data/matches_connection_model.dart';
import 'package:linkup/features/lobby/data/lobby_socket_service.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:meta/meta.dart';

part 'lobby_event.dart';
part 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  StreamSubscription<String>? _socketSubscription;

  LobbyBloc() : super(LobbyBefore8()) {
    on<ConnectLobbyEvent>((event, emit) async {
      log("[LobbyBloc] Connecting to lobby socket...");
      try {
        await LobbySocketService.connect();
        _socketSubscription = LobbySocketService.lobbyMessageStream.listen((
          raw,
        ) {
          final data = jsonDecode(raw);
          log("[LobbyBloc] Received message: $data");

          if (data["type"] == "lobby") {
            if (data["matched"] == true) {
              log("[LobbyBloc] Match found. Dispatching LobbyMatchFoundEvent.");
              final model = MatchesConnectionModel.fromJson(data["candidate"]);
              add(
                LobbyMatchFoundEvent(
                  candidate: MatchesConnectionEntity(
                    id: model.id,
                    username: model.username,
                    profilePictureMetaData: model.profilePictureMetaData,
                  ),
                ),
              );
            } else if (data["matched"] == false) {
              log(
                "[LobbyBloc] No match found. Dispatching LobbyMatchNotFoundEvent.",
              );
              add(LobbyMatchNotFoundEvent());
            }

            if (data["event"] == "event-start") {
              log("[LobbyBloc] Event started. Dispatching StartLobbyEvent.");
              add(StartLobbyEvent());
            } else if (data["event"] == "event-end") {
              log("[LobbyBloc] Event ended. Dispatching EndLobbyEvent.");
              add(EndLobbyEvent());
            }
          }
        });
      } catch (e, stackTrace) {
        log(
          "[LobbyBloc] Failed to connect to lobby socket: $e",
          stackTrace: stackTrace,
        );
        emit(LobbyError());
      }
    });

    on<DisconnectLobbyEvent>((event, emit) async {
      log("[LobbyBloc] Disconnecting from lobby socket...");
      _socketSubscription?.cancel();
      LobbySocketService.disconnect();
      emit(LobbyBefore8());
    });

    on<LobbyMatchFoundEvent>((event, emit) async {
      log(
        "[LobbyBloc] Emitting LobbyMatchFound with candidate: ${event.candidate}",
      );
      emit(LobbyMatchFound(candidate: event.candidate));
    });

    on<LobbyMatchNotFoundEvent>((event, emit) async {
      log("[LobbyBloc] Emitting LobbyNotMatchFound");
      emit(LobbyNotMatchFound());
    });

    on<StartLobbyEvent>((event, emit) async {
      log("[LobbyBloc] Emitting LobbyAt8 (Event Started)");
      emit(LobbyAt8());
    });

    on<EndLobbyEvent>((event, emit) async {
      log("[LobbyBloc] Emitting LobbyBefore8 (Event Ended)");
      emit(LobbyBefore8());
    });
  }

  @override
  Future<void> close() {
    log("[LobbyBloc] Bloc closing. Cancelling socket subscription...");
    _socketSubscription?.cancel();
    return super.close();
  }
}

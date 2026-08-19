import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/features/connections/data/connections_socket_services.dart';
import 'package:meta/meta.dart';

part 'connections_socket_event.dart';
part 'connections_socket_state.dart';

class ConnectionsSocketBloc
    extends Bloc<ConnectionsSocketEvent, ConnectionsSocketState> {
  final String _logTag = "ConnectionSocketBloc";
  final ConnectionsSocketService _connectionsSocket;

  ConnectionsSocketBloc({ConnectionsSocketService? connectionsSocket})
    : _connectionsSocket =
          connectionsSocket ?? ConnectionsSocketService.instance(),
      super(ConnectionsSocketInitial()) {
    on<LoadConnectionSocketsEvent>((event, emit) async {
      emit(ConnectionsSocketsConnecting());
      try {
        await _connectionsSocket.connect();
        emit(ConnectionsSocketsConnected());
      } catch (e) {
        log("Failed : $e", name: _logTag);
        emit(ConnectionsSocketsError());
      }
    });
  }
}

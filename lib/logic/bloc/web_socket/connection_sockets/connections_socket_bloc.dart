import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/data/websocket_services/connections_socket_services/connections_socket_services.dart';
import 'package:meta/meta.dart';

part 'connections_socket_event.dart';
part 'connections_socket_state.dart';

class ConnectionsSocketBloc
    extends Bloc<ConnectionsSocketEvent, ConnectionsSocketState> {
  final String _logTag = "ConnectionSocketBloc";

  ConnectionsSocketBloc() : super(ConnectionsSocketInitial()) {
    on<LoadConnectionSocketsEvent>((event, emit) async {
      emit(ConnectionsSocketsConnecting());
      try {
        await ConnectionsSocketService.instance().connect();
        emit(ConnectionsSocketsConnected());
      } catch (e) {
        log("Failed : $e", name: _logTag);
        emit(ConnectionsSocketsError());
      }
    });
  }
}

import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'web_socket_event.dart';
part 'web_socket_state.dart';

class WebSocketBloc extends Bloc<WebSocketEvent, WebSocketState> {
  WebSocketBloc() : super(WebSocketInitial()) {
    on<WebSocketEvent>((event, emit) {
      emit(WebSocketConnecting());
      try {
        emit(WebSocketConnected());
      } catch (e) {
        log("WebSocket error: $e");
        emit(WebSocketError());
      }
    });
  }
}

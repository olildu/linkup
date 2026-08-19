import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/presentation/bloc/web_socket_bloc.dart';

void main() {
  test('any event emits Connecting then Connected', () async {
    final bloc = WebSocketBloc();
    expect(bloc.state, isA<WebSocketInitial>());

    final states = <WebSocketState>[];
    bloc.stream.listen(states.add);
    bloc.add(LoadWebSockEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, [isA<WebSocketConnecting>(), isA<WebSocketConnected>()]);
    await bloc.close();
  });
}

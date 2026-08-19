import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_socket_bloc.dart';

import '../../../../helpers/fake_socket_services.dart';

void main() {
  test('LoadConnectionSocketsEvent emits Connecting then Connected', () async {
    final socket = FakeConnectionsSocketService();
    final bloc = ConnectionsSocketBloc(connectionsSocket: socket);
    final states = <ConnectionsSocketState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadConnectionSocketsEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states, [
      isA<ConnectionsSocketsConnecting>(),
      isA<ConnectionsSocketsConnected>(),
    ]);
    expect(socket.connectCalled, isTrue);
    await bloc.close();
  });

  test('connect failure emits ConnectionsSocketsError', () async {
    final socket = FakeConnectionsSocketService()
      ..connectError = Exception('down');
    final bloc = ConnectionsSocketBloc(connectionsSocket: socket);
    final states = <ConnectionsSocketState>[];
    bloc.stream.listen(states.add);

    bloc.add(LoadConnectionSocketsEvent());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(states.last, isA<ConnectionsSocketsError>());
    await bloc.close();
  });
}

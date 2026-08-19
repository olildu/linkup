import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/lobby/presentation/bloc/lobby_bloc.dart';
import 'package:linkup/features/lobby/presentation/screens/meet_at_8_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockLobbyBloc lobbyBloc;

  setUp(() {
    lobbyBloc = MockLobbyBloc();
    when(() => lobbyBloc.add(any())).thenReturn(null);
    when(() => lobbyBloc.isClosed).thenReturn(false);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await tester.pumpWidget(buildTestWidgetWithBlocs(
      const MeetAt8Page(),
      providers: [BlocProvider<LobbyBloc>.value(value: lobbyBloc)],
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('connects to the lobby on open and disconnects on dispose',
      (tester) async {
    stubBloc<LobbyState>(lobbyBloc, LobbyBefore8());
    await pumpPage(tester);

    var events = verify(() => lobbyBloc.add(captureAny())).captured;
    expect(events.whereType<ConnectLobbyEvent>(), hasLength(1));
    expect(find.textContaining('Come back at 8 PM'), findsOneWidget);

    await tester.pumpWidget(buildTestWidget(const SizedBox()));
    events = verify(() => lobbyBloc.add(captureAny())).captured;
    expect(events.whereType<DisconnectLobbyEvent>(), hasLength(1));
  });

  testWidgets('error-ish state shows the trouble message', (tester) async {
    stubBloc<LobbyState>(lobbyBloc, LobbyError());
    await pumpPage(tester);
    expect(find.textContaining('Something went wrong'), findsOneWidget);
    await tester.pumpWidget(buildTestWidget(const SizedBox()));
  });

  testWidgets('lifecycle pause disconnects and resume reconnects',
      (tester) async {
    stubBloc<LobbyState>(lobbyBloc, LobbyBefore8());
    await pumpPage(tester);
    clearInteractions(lobbyBloc);
    when(() => lobbyBloc.add(any())).thenReturn(null);
    when(() => lobbyBloc.isClosed).thenReturn(false);

    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    final events = verify(() => lobbyBloc.add(captureAny())).captured;
    expect(events.whereType<DisconnectLobbyEvent>(), isNotEmpty);
    expect(events.whereType<ConnectLobbyEvent>(), isNotEmpty);
    await tester.pumpWidget(buildTestWidget(const SizedBox()));
  });
}

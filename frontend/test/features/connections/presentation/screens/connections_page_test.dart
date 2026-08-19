import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/presentation/bloc/connections_bloc.dart';
import 'package:linkup/features/connections/presentation/screens/connections_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockConnectionsBloc connectionsBloc;

  setUp(() {
    connectionsBloc = MockConnectionsBloc();
    when(() => connectionsBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          const ConnectionsPage(),
          providers: [
            BlocProvider<ConnectionsBloc>.value(value: connectionsBloc),
          ],
        )));
    await tester.pump();
  }

  testWidgets('reloads chat previews on open', (tester) async {
    stubBloc<ConnectionsState>(connectionsBloc, ConnectionsInitial());
    await pumpPage(tester);
    final events = verify(() => connectionsBloc.add(captureAny())).captured;
    expect(events.whereType<ReloadChatConnectionsEvent>(), hasLength(1));
  });

  testWidgets('non-loaded state shows the fallback message', (tester) async {
    stubBloc<ConnectionsState>(connectionsBloc, ConnectionsLoading());
    await pumpPage(tester);
    expect(find.text('No chats available'), findsOneWidget);
  });

  testWidgets('loaded with matches and chats renders both sections',
      (tester) async {
    stubBloc<ConnectionsState>(
        connectionsBloc,
        ConnectionsLoaded(
          matches: [makeMatchesConnection()],
          chats: [makeChatConnection()],
        ));
    await pumpPage(tester);

    expect(find.text('Your Matches'), findsOneWidget);
    expect(find.text('Your Chats'), findsOneWidget);
    expect(find.text('bob'), findsOneWidget);
    expect(find.text('last message'), findsOneWidget);
  });

  testWidgets('loaded with matches but no chats shows the chat empty state',
      (tester) async {
    stubBloc<ConnectionsState>(
        connectionsBloc,
        ConnectionsLoaded(matches: [makeMatchesConnection()], chats: const []));
    await pumpPage(tester);
    expect(find.text('No chats yet'), findsOneWidget);
  });

  testWidgets('loaded with nothing shows the full empty state',
      (tester) async {
    stubBloc<ConnectionsState>(connectionsBloc,
        ConnectionsLoaded(matches: const [], chats: const []));
    await pumpPage(tester);
    expect(find.text('No chats or matches yet'), findsOneWidget);
  });
}

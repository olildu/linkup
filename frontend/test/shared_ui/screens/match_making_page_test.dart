import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/likes/presentation/bloc/likes_bloc.dart';
import 'package:linkup/features/lobby/presentation/bloc/lobby_bloc.dart';
import 'package:linkup/shared_ui/components/common/confirmation_dialog_builder.dart';
import 'package:linkup/shared_ui/screens/match_making_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../helpers/mock_blocs.dart';
import '../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockMatchesBloc matchesBloc;
  late MockLikesBloc likesBloc;
  late MockLobbyBloc lobbyBloc;

  setUp(() {
    matchesBloc = MockMatchesBloc();
    likesBloc = MockLikesBloc();
    lobbyBloc = MockLobbyBloc();
    when(() => matchesBloc.add(any())).thenReturn(null);
    when(() => likesBloc.add(any())).thenReturn(null);
    when(() => lobbyBloc.add(any())).thenReturn(null);
    when(() => lobbyBloc.isClosed).thenReturn(false);
    stubBloc<MatchesState>(matchesBloc, MatchesInitial());
    stubBloc<LikesState>(likesBloc, LikesInitial());
    stubBloc<LobbyState>(lobbyBloc, LobbyBefore8());
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          const MatchMakingPage(),
          providers: [
            BlocProvider<MatchesBloc>.value(value: matchesBloc),
            BlocProvider<LikesBloc>.value(value: likesBloc),
            BlocProvider<LobbyBloc>.value(value: lobbyBloc),
          ],
        )));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('loads the likes count on open', (tester) async {
    await pumpPage(tester);
    final events = verify(() => likesBloc.add(captureAny())).captured;
    expect(events.whereType<LoadLikesCountEvent>(), hasLength(1));
  });

  testWidgets('shows the likes badge when there are likes', (tester) async {
    stubBloc<LikesState>(likesBloc,
        LikesLoaded(entries: const [], totalCount: 3, unseenCount: 3));
    await pumpPage(tester);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('a limit message opens the swipe limit alert and clears it',
      (tester) async {
    final controller = stubBloc<MatchesState>(matchesBloc, MatchesInitial());
    await pumpPage(tester);

    controller.add(MatchesLoaded(
        matches: const [], swipesRemaining: 0, limitMessage: 'Out of swipes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ConfirmationDialogBuilder), findsOneWidget);
    final events = verify(() => matchesBloc.add(captureAny())).captured;
    expect(events.whereType<ClearLimitMessageEvent>(), hasLength(1));
    await tester.tap(find.text('GOT IT'));
    await tester.pumpAndSettle();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/discovery/presentation/screens/matched_page.dart';
import 'package:linkup/features/messaging/domain/start_chat_use_case.dart';
import 'package:linkup/features/onboarding/presentation/components/page_title_builder_component.dart';
import 'package:linkup/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/mocks.dart';
import '../../../../helpers/test_helper.dart';

class MockStartChatUseCase extends Mock implements StartChatUseCase {}

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockProfileBloc profileBloc;
  late MockMatchesBloc matchesBloc;
  late MockStartChatUseCase startChat;

  setUp(() async {
    profileBloc = MockProfileBloc();
    matchesBloc = MockMatchesBloc();
    startChat = MockStartChatUseCase();
    stubBloc<ProfileState>(profileBloc, ProfileLoaded(user: makeUser()));
    stubBloc<MatchesState>(matchesBloc, MatchesInitial());
    when(() => matchesBloc.add(any())).thenReturn(null);
    when(() => profileBloc.add(any())).thenReturn(null);
    final sl = GetIt.instance;
    await sl.reset();
    sl.registerSingleton<StartChatUseCase>(startChat);
  });

  Future<void> pumpPage(WidgetTester tester, {bool meet8State = false}) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          MatchedPage(matchUser: makeMatchesConnection(), meet8State: meet8State),
          providers: [
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<MatchesBloc>.value(value: matchesBloc),
          ],
        )));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('shows the congratulations copy with both profile photos',
      (tester) async {
    await pumpPage(tester);
    expect(find.byType(PageTitle), findsOneWidget);
    expect(find.text('Start Messaging'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // confetti winds down
  });

  testWidgets('back arrow clears the match user and pops', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pump(const Duration(seconds: 4));
    final events = verify(() => matchesBloc.add(captureAny())).captured;
    expect(events.whereType<ClearMatchUserEvent>(), hasLength(1));
  });

  testWidgets('meet8State hides the app bar and the messaging button',
      (tester) async {
    await pumpPage(tester, meet8State: true);
    expect(find.byType(AppBar), findsNothing);
    expect(find.text('Start Messaging'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
  });
}

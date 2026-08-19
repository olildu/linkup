import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:linkup/features/discovery/presentation/screens/around_you_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mock_blocs.dart';
import '../../../../helpers/test_helper.dart';

void main() {
  setUpAll(registerBlocEventFallbacks);

  late MockMatchesBloc matchesBloc;

  setUp(() {
    matchesBloc = MockMatchesBloc();
    when(() => matchesBloc.add(any())).thenReturn(null);
  });

  Future<void> pumpPage(WidgetTester tester) async {
    usePhoneSurface(tester);
    ignoreOverflowErrors();
    await mockNetworkImagesFor(() => tester.pumpWidget(buildTestWidgetWithBlocs(
          const AroundYouPage(),
          providers: [BlocProvider<MatchesBloc>.value(value: matchesBloc)],
        )));
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('initial state shows a loading spinner', (tester) async {
    stubBloc<MatchesState>(matchesBloc, MatchesInitial());
    await pumpPage(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error state shows the glitch message', (tester) async {
    stubBloc<MatchesState>(matchesBloc, MatchesError());
    await pumpPage(tester);
    expect(find.textContaining('glitch in the matrix'), findsOneWidget);
  });

  testWidgets('empty state shows the seen-all message', (tester) async {
    stubBloc<MatchesState>(matchesBloc, MatchesEmpty());
    await pumpPage(tester);
    expect(find.textContaining('seen all nearby profiles'), findsOneWidget);
  });

  testWidgets('loaded with an empty deck also shows the seen-all message',
      (tester) async {
    stubBloc<MatchesState>(matchesBloc,
        MatchesLoaded(matches: const [], swipesRemaining: 5));
    await pumpPage(tester);
    expect(find.textContaining('seen all nearby profiles'), findsOneWidget);
  });

  testWidgets('loaded deck renders the swiper with candidate details',
      (tester) async {
    stubBloc<MatchesState>(
        matchesBloc,
        MatchesLoaded(
            matches: [
              makeCandidate(id: 1, username: 'alice'),
              makeCandidate(id: 2, username: 'bea'),
            ],
            swipesRemaining: 5));
    await pumpPage(tester);
    expect(find.byType(CardSwiper), findsOneWidget);
    expect(find.textContaining('alice'), findsWidgets);
  });
}

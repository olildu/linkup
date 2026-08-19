import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/discovery/presentation/bloc/matches_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockLoadMatchesUseCase loadMatches;
  late MockSwipeUseCase swipe;

  setUp(() {
    loadMatches = MockLoadMatchesUseCase();
    swipe = MockSwipeUseCase();
  });

  MatchesBloc build() =>
      MatchesBloc(loadMatchesUseCase: loadMatches, swipeUseCase: swipe);

  Future<void> pump([int ms = 10]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  void stubLoaded({int count = 2, int? swipesRemaining = 5}) {
    when(() => loadMatches(refresh: false)).thenAnswer((_) async => (
          matches: List.generate(count, (i) => makeCandidate(id: i + 1)),
          swipesRemaining: swipesRemaining,
        ));
  }

  test('load emits Loaded with matches, Empty when none, Error on failure',
      () async {
    stubLoaded();
    final bloc = build();
    bloc.add(LoadMatchesEvent());
    await pump();
    expect((bloc.state as MatchesLoaded).matches, hasLength(2));

    when(() => loadMatches(refresh: false))
        .thenAnswer((_) async => (matches: <MatchCandidateEntity>[], swipesRemaining: 0));
    bloc.add(LoadMatchesEvent());
    await pump();
    expect(bloc.state, isA<MatchesEmpty>());

    when(() => loadMatches(refresh: false)).thenThrow(Exception('down'));
    bloc.add(LoadMatchesEvent());
    await pump();
    expect(bloc.state, isA<MatchesError>());
    await bloc.close();
  });

  test('right swipe with a match sets matchUser and updates swipes', () async {
    stubLoaded();
    when(() => swipe(1, CardSwiperDirection.right)).thenAnswer((_) async => {
          'match': true,
          'matched_user': {
            'id': 1,
            'username': 'alice',
            'profile_picture': {'url': 'a.jpg'},
          },
          'swipes_remaining': 4,
        });

    final bloc = build();
    bloc.add(LoadMatchesEvent());
    await pump();
    bloc.add(SwipeProfileEvent(
        likedId: 1, direction: CardSwiperDirection.right, previousIndex: 0));
    await pump();

    final state = bloc.state as MatchesLoaded;
    expect(state.matchUser!.username, 'alice');
    expect(state.swipesRemaining, 4);

    bloc.add(ClearMatchUserEvent());
    await pump();
    expect((bloc.state as MatchesLoaded).matchUser, isNull);
    await bloc.close();
  });

  test('right swipe without a match only updates the counter', () async {
    stubLoaded();
    when(() => swipe(1, CardSwiperDirection.right)).thenAnswer(
        (_) async => {'match': false, 'swipes_remaining': 3});

    final bloc = build();
    bloc.add(LoadMatchesEvent());
    await pump();
    bloc.add(SwipeProfileEvent(
        likedId: 1, direction: CardSwiperDirection.right, previousIndex: 0));
    await pump();

    final state = bloc.state as MatchesLoaded;
    expect(state.matchUser, isNull);
    expect(state.swipesRemaining, 3);
    await bloc.close();
  });

  test('hitting the swipe limit sets the limit message; clear resets it',
      () async {
    stubLoaded();
    when(() => swipe(1, CardSwiperDirection.right))
        .thenThrow(SwipeLimitException('Out of swipes'));

    final bloc = build();
    bloc.add(LoadMatchesEvent());
    await pump();
    bloc.add(SwipeProfileEvent(
        likedId: 1, direction: CardSwiperDirection.right, previousIndex: 0));
    await pump();

    var state = bloc.state as MatchesLoaded;
    expect(state.swipesRemaining, 0);
    expect(state.limitMessage, 'Out of swipes');

    bloc.add(ClearLimitMessageEvent());
    await pump();
    state = bloc.state as MatchesLoaded;
    expect(state.limitMessage, isNull);
    await bloc.close();
  });

  test('swiping the last card completes the deck', () async {
    stubLoaded(count: 1);
    when(() => swipe(1, CardSwiperDirection.left))
        .thenAnswer((_) async => {'match': false});

    final bloc = build();
    bloc.add(LoadMatchesEvent());
    await pump();
    bloc.add(SwipeProfileEvent(
        likedId: 1, direction: CardSwiperDirection.left, previousIndex: 0));
    await pump();

    expect(bloc.state, isA<MatchesEmpty>());
    await bloc.close();
  });
}

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/data/chats_connection_model.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:linkup/features/discovery/data/match_repository_impl.dart';
import 'package:linkup/features/discovery/data/matches_connection_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockMatchRemoteDatasource matchDs;
  late MockSwipeRemoteDatasource swipeDs;
  late MockChatLocalDatasource localDs;
  late MatchRepositoryImpl repo;

  setUp(() {
    matchDs = MockMatchRemoteDatasource();
    swipeDs = MockSwipeRemoteDatasource();
    localDs = MockChatLocalDatasource();
    repo = MatchRepositoryImpl(
      matchDatasource: matchDs,
      swipeDatasource: swipeDs,
      chatLocalDatasource: localDs,
    );
  });

  test('getMatchUsers maps candidate models to entities', () async {
    when(() => matchDs.getMatchUsers(refresh: true)).thenAnswer((_) async => (
          matches: [
            MatchCandidateModel(
              id: 7,
              username: 'alice',
              gender: 'Female',
              universityId: 1,
              profilePictureMetaData: const {'url': 'p'},
              dob: DateTime(2000),
              universityMajor: 'CS',
              universityYear: 3,
              photos: const [],
              about: 'a',
              currentlyStaying: 'PG',
              hometown: 'Home',
              height: 160,
            ),
          ],
          swipesRemaining: 3,
        ));

    final result = await repo.getMatchUsers(refresh: true);
    expect(result.matches.single.username, 'alice');
    expect(result.matches.single.height, 160);
    expect(result.swipesRemaining, 3);
  });

  test('swipe delegates to the swipe datasource', () async {
    when(() => swipeDs.swipe(7, CardSwiperDirection.right))
        .thenAnswer((_) async => {'match': true});
    expect(await repo.swipe(7, CardSwiperDirection.right), {'match': true});
  });

  test('getConnections maps matches and chats', () async {
    when(() => matchDs.getConnections()).thenAnswer((_) async => (
          matches: [
            MatchesConnectionModel(
                id: 4, username: 'carol', profilePictureMetaData: const {}),
          ],
          chats: [
            ChatsConnectionModel(
              id: 3,
              username: 'bob',
              profilePictureMetaData: const {},
              chatRoomId: 10,
              unseenCounter: 1,
            ),
          ],
        ));

    final result = await repo.getConnections();
    expect(result.matches.single.username, 'carol');
    expect(result.chats.single.chatRoomId, 10);
  });

  test('cacheConnections and getCachedConnections round-trip via local store',
      () async {
    when(() => localDs.replaceAll(any())).thenAnswer((_) async {});
    await repo.cacheConnections([makeChatConnection()]);
    final saved = verify(() => localDs.replaceAll(captureAny())).captured.single
        as List<ChatsConnectionModel>;
    expect(saved.single.username, 'bob');

    when(() => localDs.getAll()).thenAnswer((_) async => saved);
    final cached = await repo.getCachedConnections();
    expect(cached.single.chatRoomId, 10);
  });
}

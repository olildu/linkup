import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/data/likes_repository_impl.dart';
import 'package:linkup/features/likes/data/likes_you_entry_model.dart';
import 'package:linkup/features/likes/data/likes_you_response_model.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockLikesRemoteDatasource ds;
  late LikesRepositoryImpl repo;

  setUp(() {
    ds = MockLikesRemoteDatasource();
    repo = LikesRepositoryImpl(likesDatasource: ds);
  });

  test('getReceivedLikes maps models to entities including profiles',
      () async {
    when(() => ds.getReceivedLikes(offset: 0)).thenAnswer(
      (_) async => LikesYouResponseModel(
        entries: [
          LikesYouEntryModel(
            id: 1,
            revealed: true,
            profile: MatchCandidateModel(
              id: 1,
              username: 'alice',
              gender: 'Female',
              universityId: 1,
              profilePictureMetaData: const {},
              dob: DateTime(2000),
              universityMajor: 'CS',
              universityYear: 3,
              photos: const [],
              about: '',
              currentlyStaying: '',
              hometown: '',
            ),
          ),
          LikesYouEntryModel(id: 2, revealed: false, firstPhoto: const {}),
        ],
        totalCount: 2,
        unseenCount: 1,
      ),
    );

    final result = await repo.getReceivedLikes();
    expect(result.totalCount, 2);
    expect(result.entries.first.profile!.username, 'alice');
    expect(result.entries.last.profile, isNull);
  });

  test('count/likeBack/passLike delegate', () async {
    when(() => ds.getLikesCount()).thenAnswer((_) async => 3);
    expect(await repo.getLikesCount(), 3);

    when(() => ds.likeBack(5)).thenAnswer((_) async => {'match': false});
    expect(await repo.likeBack(5), {'match': false});

    when(() => ds.passLike(5)).thenAnswer((_) async {});
    await repo.passLike(5);
    verify(() => ds.passLike(5)).called(1);
  });
}

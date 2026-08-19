import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:linkup/features/profile/data/models/user_model.dart';
import 'package:linkup/features/profile/data/models/user_preference_model.dart';
import 'package:linkup/features/profile/data/user_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  setUpAll(() => registerFallbackValue(UserPreferenceModel()));

  late MockUserRemoteDatasource ds;
  late UserRepositoryImpl repo;

  setUp(() {
    ds = MockUserRemoteDatasource();
    repo = UserRepositoryImpl(ds);
  });

  test('getProfile maps the model to a UserEntity', () async {
    when(() => ds.getProfile()).thenAnswer((_) async => UserModel(
          id: 1,
          universityId: 2,
          username: 'me',
          height: 180,
        ));
    final user = await repo.getProfile();
    expect(user.id, 1);
    expect(user.username, 'me');
    expect(user.height, 180);
  });

  test('getOtherProfile maps the candidate model', () async {
    when(() => ds.getOtherProfile(7)).thenAnswer((_) async =>
        MatchCandidateModel(
          id: 7,
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
        ));
    expect((await repo.getOtherProfile(7)).username, 'alice');
  });

  test('updateProfile forwards the flag', () async {
    final data = UpdateMetadataModel(about: 'x');
    when(() => ds.updateProfile(data, updatePfp: true))
        .thenAnswer((_) async {});
    await repo.updateProfile(data, updatePfp: true);
    verify(() => ds.updateProfile(data, updatePfp: true)).called(1);
  });

  test('preference round-trip converts between entity and model', () async {
    when(() => ds.getPreference()).thenAnswer(
        (_) async => UserPreferenceModel(interestedGender: 'female'));
    expect((await repo.getPreference()).interestedGender, 'female');

    when(() => ds.updatePreference(any())).thenAnswer((_) async {});
    await repo.updatePreference(makePreference());
    final sent = verify(() => ds.updatePreference(captureAny()))
        .captured
        .single as UserPreferenceModel;
    expect(sent.interestedGender, 'female');
    expect(sent.height, 165);
  });

  test('deleteAccount, blockUser, reportUser delegate', () async {
    when(() => ds.deleteAccount()).thenAnswer((_) async {});
    await repo.deleteAccount();
    verify(() => ds.deleteAccount()).called(1);

    when(() => ds.blockUser(9)).thenAnswer((_) async {});
    await repo.blockUser(9);
    verify(() => ds.blockUser(9)).called(1);

    when(() => ds.reportUser(9, 'spam')).thenAnswer((_) async {});
    await repo.reportUser(9, 'spam');
    verify(() => ds.reportUser(9, 'spam')).called(1);
  });
}

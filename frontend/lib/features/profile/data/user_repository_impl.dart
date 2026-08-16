import 'package:linkup/features/profile/data/user_remote_datasource.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/profile/data/models/user_preference_model.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/profile/domain/user_entity.dart';
import 'package:linkup/features/profile/domain/user_preference_entity.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDatasource _datasource;

  const UserRepositoryImpl(this._datasource);

  @override
  Future<UserEntity> getProfile() async {
    final model = await _datasource.getProfile();
    return UserEntity(
      id: model.id,
      username: model.username,
      gender: model.gender,
      universityId: model.universityId,
      profilePicture: model.profilePicture,
      dob: model.dob,
      interestedGender: model.interestedGender,
      universityMajor: model.universityMajor,
      universityYear: model.universityYear,
      photos: model.photos,
      about: model.about,
      currentlyStaying: model.currentlyStaying,
      hometown: model.hometown,
      height: model.height,
      weight: model.weight,
      religion: model.religion,
      smokingInfo: model.smokingInfo,
      drinkingInfo: model.drinkingInfo,
      lookingFor: model.lookingFor,
    );
  }

  @override
  Future<MatchCandidateEntity> getOtherProfile(int userId) async {
    final model = await _datasource.getOtherProfile(userId);
    return MatchCandidateEntity(
      id: model.id,
      username: model.username,
      gender: model.gender,
      universityId: model.universityId,
      profilePictureMetaData: model.profilePictureMetaData,
      dob: model.dob,
      universityMajor: model.universityMajor,
      universityYear: model.universityYear,
      photos: model.photos,
      about: model.about,
      currentlyStaying: model.currentlyStaying,
      hometown: model.hometown,
      height: model.height,
      weight: model.weight,
      religion: model.religion,
      smokingInfo: model.smokingInfo,
      drinkingInfo: model.drinkingInfo,
      lookingFor: model.lookingFor,
    );
  }

  @override
  Future<void> updateProfile(
    UpdateMetadataModel data, {
    bool updatePfp = false,
  }) => _datasource.updateProfile(data, updatePfp: updatePfp);

  @override
  Future<UserPreferenceEntity> getPreference() async {
    final model = await _datasource.getPreference();
    return UserPreferenceEntity(
      interestedGender: model.interestedGender,
      height: model.height,
      weight: model.weight,
      religion: model.religion,
      drinkingStatus: model.drinkingStatus,
      smokingStatus: model.smokingStatus,
      lookingFor: model.lookingFor,
      currentlyStaying: model.currentlyStaying,
    );
  }

  @override
  Future<void> updatePreference(UserPreferenceEntity preference) =>
      _datasource.updatePreference(
        UserPreferenceModel(
          interestedGender: preference.interestedGender,
          height: preference.height,
          weight: preference.weight,
          religion: preference.religion,
          drinkingStatus: preference.drinkingStatus,
          smokingStatus: preference.smokingStatus,
          lookingFor: preference.lookingFor,
          currentlyStaying: preference.currentlyStaying,
        ),
      );

  @override
  Future<void> deleteAccount() => _datasource.deleteAccount();

  @override
  Future<void> blockUser(int userId) => _datasource.blockUser(userId);

  @override
  Future<void> reportUser(int userId, String reason) =>
      _datasource.reportUser(userId, reason);
}

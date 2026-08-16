import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/profile/domain/user_entity.dart';
import 'package:linkup/features/profile/domain/user_preference_entity.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';

abstract class UserRepository {
  Future<UserEntity> getProfile();
  Future<MatchCandidateEntity> getOtherProfile(int userId);
  Future<void> updateProfile(
    UpdateMetadataModel data, {
    bool updatePfp = false,
  });
  Future<UserPreferenceEntity> getPreference();
  Future<void> updatePreference(UserPreferenceEntity preference);
  Future<void> deleteAccount();
  Future<void> blockUser(int userId);
  Future<void> reportUser(int userId, String reason);
}

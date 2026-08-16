import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

class GetOtherProfileUseCase {
  final UserRepository _repository;
  const GetOtherProfileUseCase(this._repository);

  Future<MatchCandidateEntity> call(int userId) =>
      _repository.getOtherProfile(userId);
}

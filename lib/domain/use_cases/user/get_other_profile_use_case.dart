import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

class GetOtherProfileUseCase {
  final UserRepository _repository;
  const GetOtherProfileUseCase(this._repository);

  Future<MatchCandidateEntity> call(int userId) => _repository.getOtherProfile(userId);
}

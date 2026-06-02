import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/repositories/match_repository.dart';

class LoadMatchesUseCase {
  final MatchRepository _repository;
  const LoadMatchesUseCase(this._repository);

  Future<List<MatchCandidateEntity>> call() => _repository.getMatchUsers();
}

import 'package:linkup/features/likes/domain/likes_repository.dart';

class GetLikesCountUseCase {
  final LikesRepository _repository;
  const GetLikesCountUseCase(this._repository);

  Future<int> call() => _repository.getLikesCount();
}

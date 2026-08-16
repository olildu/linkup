import 'package:linkup/features/likes/domain/likes_repository.dart';

class PassLikeUseCase {
  final LikesRepository _repository;
  const PassLikeUseCase(this._repository);

  Future<void> call(int likerId) => _repository.passLike(likerId);
}

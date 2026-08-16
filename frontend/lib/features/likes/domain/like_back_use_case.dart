import 'package:linkup/features/likes/domain/likes_repository.dart';

class LikeBackUseCase {
  final LikesRepository _repository;
  const LikeBackUseCase(this._repository);

  Future<Map<String, dynamic>> call(int likerId) =>
      _repository.likeBack(likerId);
}

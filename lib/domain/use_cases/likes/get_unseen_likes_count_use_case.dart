import 'package:linkup/domain/repositories/likes_repository.dart';

class GetUnseenLikesCountUseCase {
  final LikesRepository _repository;
  const GetUnseenLikesCountUseCase(this._repository);

  Future<int> call() => _repository.getUnseenCount();
}

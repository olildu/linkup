import 'package:linkup/features/profile/domain/user_repository.dart';

class BlockUserUseCase {
  final UserRepository _repository;
  const BlockUserUseCase(this._repository);

  Future<void> call(int userId) => _repository.blockUser(userId);
}

import 'package:linkup/features/profile/domain/user_entity.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

class GetProfileUseCase {
  final UserRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<UserEntity> call() => _repository.getProfile();
}

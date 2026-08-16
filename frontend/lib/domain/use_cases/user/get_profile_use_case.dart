import 'package:linkup/domain/entities/user_entity.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

class GetProfileUseCase {
  final UserRepository _repository;
  const GetProfileUseCase(this._repository);

  Future<UserEntity> call() => _repository.getProfile();
}

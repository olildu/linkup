import 'package:linkup/domain/entities/user_preference_entity.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

class GetPreferenceUseCase {
  final UserRepository _repository;
  const GetPreferenceUseCase(this._repository);

  Future<UserPreferenceEntity> call() => _repository.getPreference();
}

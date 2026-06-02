import 'package:linkup/domain/entities/user_preference_entity.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

class UpdatePreferenceUseCase {
  final UserRepository _repository;
  const UpdatePreferenceUseCase(this._repository);

  Future<void> call(UserPreferenceEntity preference) =>
      _repository.updatePreference(preference);
}

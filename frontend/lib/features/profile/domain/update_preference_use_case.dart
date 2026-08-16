import 'package:linkup/features/profile/domain/user_preference_entity.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

class UpdatePreferenceUseCase {
  final UserRepository _repository;
  const UpdatePreferenceUseCase(this._repository);

  Future<void> call(UserPreferenceEntity preference) =>
      _repository.updatePreference(preference);
}

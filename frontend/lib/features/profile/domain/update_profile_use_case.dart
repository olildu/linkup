import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/profile/domain/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<void> call(UpdateMetadataModel data, {bool updatePfp = false}) =>
      _repository.updateProfile(data, updatePfp: updatePfp);
}

import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/domain/repositories/user_repository.dart';

class UpdateProfileUseCase {
  final UserRepository _repository;
  const UpdateProfileUseCase(this._repository);

  Future<void> call(UpdateMetadataModel data, {bool updatePfp = false}) =>
      _repository.updateProfile(data, updatePfp: updatePfp);
}

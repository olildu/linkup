import 'package:linkup/core/entities/update_metadata_model.dart';
import 'package:linkup/features/auth/domain/repositories/auth_repository.dart';

class CompleteProfileUseCase {
  final AuthRepository _repository;
  const CompleteProfileUseCase(this._repository);

  Future<bool> call(UpdateMetadataModel data) =>
      _repository.completeProfile(data);
}

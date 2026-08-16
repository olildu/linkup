import 'package:linkup/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;
  const DeleteAccountUseCase(this._repository);

  Future<void> call() => _repository.deleteAccount();
}

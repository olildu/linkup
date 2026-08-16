import 'package:linkup/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;
  const ResetPasswordUseCase(this._repository);

  Future<void> call(String emailHash, String password) =>
      _repository.resetPassword(emailHash, password);
}

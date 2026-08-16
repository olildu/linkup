import 'package:linkup/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<void> call(String emailHash, String password) =>
      _repository.register(emailHash, password);
}

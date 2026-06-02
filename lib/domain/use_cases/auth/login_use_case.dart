import 'package:linkup/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<void> call(String email, String password) =>
      _repository.login(email, password);
}

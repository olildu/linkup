import 'package:linkup/domain/repositories/auth_repository.dart';

class SendOTPUseCase {
  final AuthRepository _repository;
  const SendOTPUseCase(this._repository);

  Future<int> call(String email) => _repository.sendEmailOTP(email);
}

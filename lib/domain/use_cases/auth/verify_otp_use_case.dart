import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/domain/repositories/auth_repository.dart';

class VerifyOTPUseCase {
  final AuthRepository _repository;
  const VerifyOTPUseCase(this._repository);

  Future<Map<String, dynamic>> call(
    String email,
    int otp,
    EmailOTPSubject subject,
  ) => _repository.verifyEmailOTP(email, otp, subject);
}

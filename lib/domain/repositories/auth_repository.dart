import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/data/models/update_metadata_model.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String emailHash, String password);
  Future<void> resetPassword(String emailHash, String password);
  Future<int> sendEmailOTP(String email);
  Future<Map<String, dynamic>> verifyEmailOTP(
    String email,
    int otp,
    EmailOTPSubject subject,
  );
  Future<bool> completeProfile(UpdateMetadataModel data);
  Future<void> logout();
  Future<void> deleteAccount();
}

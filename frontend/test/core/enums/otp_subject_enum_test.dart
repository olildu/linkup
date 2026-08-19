import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';

void main() {
  test('value maps each subject to its wire string', () {
    expect(EmailOTPSubject.emailVerification.value, 'email_verification');
    expect(EmailOTPSubject.forgotPassword.value, 'forgot_password');
  });
}

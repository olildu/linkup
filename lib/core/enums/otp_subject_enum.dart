enum EmailOTPSubject {
  emailVerification,
  forgotPassword;

  String get value {
    switch (this) {
      case EmailOTPSubject.emailVerification:
        return 'email_verification';
      case EmailOTPSubject.forgotPassword:
        return 'forgot_password';
    }
  }
}

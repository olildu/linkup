class ValidationUtils {
  static bool validateEmail(String email) {
    final isEmailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
    return isEmailValid;
  }

  static bool validateOTP(String otp) {
    return otp.length == 6 ? true : false;
  }

  static bool validatePassword(String password, {bool isLogin = false}) {
    if (password.length < 8) return false;
    if (isLogin && password.length > 7) return true;

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasUppercase && hasLowercase && hasDigit && hasSpecial;
  }
}

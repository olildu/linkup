part of 'otp_bloc.dart';

@immutable
sealed class OtpBlocEvent {}

final class SendOTPEvent extends OtpBlocEvent {
  final String email;
  SendOTPEvent({required this.email});
}

final class CompleteSignUpEvent extends OtpBlocEvent {
  final String password;
  CompleteSignUpEvent({required this.password});
}

final class VerifyOTPEvent extends OtpBlocEvent {
  final int otp;
  final String email;
  final EmailOTPSubject subject;

  VerifyOTPEvent({
    required this.otp,
    required this.email,
    required this.subject,
  });
}

final class ResetPasswordSubmittedEvent extends OtpBlocEvent {
  final String password;
  ResetPasswordSubmittedEvent({required this.password});
}

final class OtpVerificationErrorEvent extends OtpBlocEvent {}

final class EmailSendErrorEvent extends OtpBlocEvent {}

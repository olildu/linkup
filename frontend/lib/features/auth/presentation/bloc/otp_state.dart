part of 'otp_bloc.dart';

@immutable
sealed class OtpState {}

final class OtpInitial extends OtpState {}

final class OtpLoading extends OtpState {}

final class OtpSent extends OtpState {}

final class OtpVerified extends OtpState {
  final String emailHash;
  OtpVerified({required this.emailHash});
}

final class OtpFailure extends OtpState {
  final String message;
  OtpFailure({required this.message});
}

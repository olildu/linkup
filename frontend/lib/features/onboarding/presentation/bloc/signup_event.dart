part of 'signup_bloc.dart';

@immutable
sealed class SignupEvent {}

final class SignupInit extends SignupEvent {
  final SignUpPageFlow signUpPageFlow;
  final int currentIndex;

  SignupInit({required this.signUpPageFlow, required this.currentIndex});
}

final class SignupNext extends SignupEvent {}

final class SignupPrevious extends SignupEvent {}

final class SignupUpload extends SignupEvent {}

final class SignupOptionalFilled extends SignupEvent {}

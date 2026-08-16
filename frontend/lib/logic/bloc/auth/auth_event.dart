part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

final class AuthRegisterRequested extends AuthEvent {
  final String emailHash;
  final String password;
  AuthRegisterRequested({required this.emailHash, required this.password});
}

final class AuthResetPasswordRequested extends AuthEvent {
  final String emailHash;
  final String password;
  AuthResetPasswordRequested({required this.emailHash, required this.password});
}

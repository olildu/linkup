part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}

final class AuthAccountNotFound extends AuthState {
  final String message;
  AuthAccountNotFound({required this.message});
}

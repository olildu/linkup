part of 'post_login_bloc.dart';

@immutable
sealed class PostLoginState {}

final class PostLoginInitial extends PostLoginState {}

final class PostLoginLoading extends PostLoginState {}

final class PostLoginError extends PostLoginState {}

final class PostLoginLoaded extends PostLoginState {
  final bool goToSignUpPage;

  PostLoginLoaded({this.goToSignUpPage = true});
}

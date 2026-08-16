part of 'post_login_bloc.dart';

@immutable
sealed class PostLoginEvent {}

final class StartPostLoginEvent extends PostLoginEvent {}

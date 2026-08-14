part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileError extends ProfileState {}

final class ProfileUpdating extends ProfileState {
  final int current;
  final int total;
  final String message;

  ProfileUpdating({
    required this.current,
    required this.total,
    required this.message,
  });
}

final class ProfileLoaded extends ProfileState {
  final UserEntity user;

  ProfileLoaded({required this.user});
}

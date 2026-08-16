part of 'other_profile_bloc.dart';

@immutable
sealed class OtherProfileState {}

final class OtherProfileInitial extends OtherProfileState {}

final class OtherProfileLoading extends OtherProfileState {}

final class OtherProfileLoaded extends OtherProfileState {
  final MatchCandidateEntity user;
  OtherProfileLoaded({required this.user});
}

final class OtherProfileError extends OtherProfileState {}

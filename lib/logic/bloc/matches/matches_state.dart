part of 'matches_bloc.dart';

@immutable
sealed class MatchesState {}

final class MatchesInitial extends MatchesState {}

final class MatchesLoading extends MatchesState {}

final class MatchesError extends MatchesState {}

final class MatchesEmpty extends MatchesState {}

final class MatchesLoaded extends MatchesState {
  final List<MatchCandidateEntity> matches;
  final MatchesConnectionEntity? matchUser;

  MatchesLoaded({required this.matches, this.matchUser});

  MatchesLoaded copyWith({
    List<MatchCandidateEntity>? matches,
    MatchesConnectionEntity? matchUser,
    bool clearMatchUser = false,
  }) {
    return MatchesLoaded(
      matches: matches ?? this.matches,
      matchUser: clearMatchUser ? null : (matchUser ?? this.matchUser),
    );
  }
}

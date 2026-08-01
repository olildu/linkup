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
  final int? swipesRemaining;
  final String? limitMessage;

  MatchesLoaded({required this.matches, this.matchUser, this.swipesRemaining, this.limitMessage});

  MatchesLoaded copyWith({
    List<MatchCandidateEntity>? matches,
    MatchesConnectionEntity? matchUser,
    bool clearMatchUser = false,
    int? swipesRemaining,
    String? limitMessage,
    bool clearLimitMessage = false,
  }) {
    return MatchesLoaded(
      matches: matches ?? this.matches,
      matchUser: clearMatchUser ? null : (matchUser ?? this.matchUser),
      swipesRemaining: swipesRemaining ?? this.swipesRemaining,
      limitMessage: clearLimitMessage ? null : (limitMessage ?? this.limitMessage),
    );
  }
}

part of 'likes_bloc.dart';

@immutable
sealed class LikesState {}

final class LikesInitial extends LikesState {}

final class LikesError extends LikesState {}

final class LikesLoaded extends LikesState {
  final List<LikesYouEntryEntity> entries;
  final int totalCount;
  final int unseenCount;
  final bool loadingEntries;
  final MatchesConnectionEntity? matchUser;

  LikesLoaded({
    required this.entries,
    required this.totalCount,
    required this.unseenCount,
    this.loadingEntries = false,
    this.matchUser,
  });

  LikesLoaded copyWith({
    List<LikesYouEntryEntity>? entries,
    int? totalCount,
    int? unseenCount,
    bool? loadingEntries,
    MatchesConnectionEntity? matchUser,
    bool clearMatchUser = false,
  }) {
    return LikesLoaded(
      entries: entries ?? this.entries,
      totalCount: totalCount ?? this.totalCount,
      unseenCount: unseenCount ?? this.unseenCount,
      loadingEntries: loadingEntries ?? this.loadingEntries,
      matchUser: clearMatchUser ? null : (matchUser ?? this.matchUser),
    );
  }
}

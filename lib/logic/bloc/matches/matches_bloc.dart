import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/entities/matches_connection_entity.dart';
import 'package:linkup/domain/use_cases/match/load_matches_use_case.dart';
import 'package:linkup/domain/use_cases/match/swipe_use_case.dart';
import 'package:meta/meta.dart';

part 'matches_event.dart';
part 'matches_state.dart';

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  final LoadMatchesUseCase _loadMatches;
  final SwipeUseCase _swipe;

  MatchesBloc({
    required LoadMatchesUseCase loadMatchesUseCase,
    required SwipeUseCase swipeUseCase,
  })  : _loadMatches = loadMatchesUseCase,
        _swipe = swipeUseCase,
        super(MatchesInitial()) {
    on<LoadMatchesEvent>((event, emit) async {
      emit(MatchesLoading());
      try {
        final matches = await _loadMatches();
        log(matches.toString(), name: 'MatchesBloc');
        if (matches.isEmpty) {
          emit(MatchesEmpty());
          return;
        }
        emit(MatchesLoaded(matches: matches));
      } on Exception catch (e, st) {
        log('Error loading matches: $e', stackTrace: st);
        emit(MatchesError());
      }
    });

    on<MatchesDeckCompletedEvent>((event, emit) => emit(MatchesEmpty()));

    on<ClearMatchUserEvent>((event, emit) {
      if (state is MatchesLoaded) {
        emit((state as MatchesLoaded).copyWith(clearMatchUser: true));
      }
    });

    on<ClearLimitMessageEvent>((event, emit) {
      if (state is MatchesLoaded) {
        emit((state as MatchesLoaded).copyWith(clearLimitMessage: true));
      }
    });

    on<SwipeProfileEvent>((event, emit) async {
      if (state is! MatchesLoaded) return;
      final nowState = state as MatchesLoaded;

      final isLastCard = event.previousIndex == (nowState.matches.length - 1);

      Map<String, dynamic> response;
      try {
        response = await _swipe(event.likedId, event.direction);
      } on SwipeLimitException catch (e) {
        emit(nowState.copyWith(swipesRemaining: 0, limitMessage: e.message));
        if (isLastCard) add(MatchesDeckCompletedEvent());
        return;
      }

      if (event.direction == CardSwiperDirection.right && response['match'] == true) {
        final matchedUserJson = Map<String, dynamic>.from(response['matched_user']);
        final newMatchUser = MatchesConnectionEntity(
          id: matchedUserJson['id'] as int,
          username: matchedUserJson['username'] as String,
          profilePictureMetaData: matchedUserJson['profile_picture'] as Map,
        );
        emit(nowState.copyWith(matchUser: newMatchUser, swipesRemaining: response['swipes_remaining'] as int?));
      } else if (event.direction == CardSwiperDirection.right) {
        emit(nowState.copyWith(swipesRemaining: response['swipes_remaining'] as int?));
      }

      if (isLastCard) add(MatchesDeckCompletedEvent());
    });
  }
}

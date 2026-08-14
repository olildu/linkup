import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/data/websocket_services/connections_socket_services/connections_socket_services.dart';
import 'package:linkup/domain/entities/likes_you_entry_entity.dart';
import 'package:linkup/domain/entities/matches_connection_entity.dart';
import 'package:linkup/domain/use_cases/likes/get_received_likes_use_case.dart';
import 'package:linkup/domain/use_cases/likes/get_unseen_likes_count_use_case.dart';
import 'package:linkup/domain/use_cases/likes/like_back_use_case.dart';
import 'package:linkup/domain/use_cases/likes/pass_like_use_case.dart';
import 'package:meta/meta.dart';

part 'likes_event.dart';
part 'likes_state.dart';

class LikesBloc extends Bloc<LikesEvent, LikesState> {
  StreamSubscription<String>? _connectionsSocketSubscription;
  bool _socketInitialized = false;
  final String _logTag = 'LikesBloc';

  final GetReceivedLikesUseCase _getReceivedLikes;
  final GetUnseenLikesCountUseCase _getUnseenCount;
  final LikeBackUseCase _likeBack;
  final PassLikeUseCase _passLike;

  LikesBloc({
    required GetReceivedLikesUseCase getReceivedLikesUseCase,
    required GetUnseenLikesCountUseCase getUnseenLikesCountUseCase,
    required LikeBackUseCase likeBackUseCase,
    required PassLikeUseCase passLikeUseCase,
  }) : _getReceivedLikes = getReceivedLikesUseCase,
       _getUnseenCount = getUnseenLikesCountUseCase,
       _likeBack = likeBackUseCase,
       _passLike = passLikeUseCase,
       super(LikesInitial()) {
    on<LoadUnseenCountEvent>(_onLoadUnseenCount);
    on<LoadReceivedLikesEvent>(_onLoadReceivedLikes);
    on<LikeBackEvent>(_onLikeBack);
    on<PassLikeEvent>(_onPassLike);
    on<ClearLikesMatchUserEvent>(_onClearMatchUser);
  }

  void _socketInit() {
    if (_socketInitialized) return;
    _socketInitialized = true;

    _connectionsSocketSubscription?.cancel();
    _connectionsSocketSubscription = ConnectionsSocketService
        .connectionsMessageStream
        .listen((raw) {
          final data = jsonDecode(raw);
          log('Likes socket data: $data', name: _logTag);
          if (data['type'] == 'connections-reload' &&
              data['sub_type'] == 'like') {
            add(LoadUnseenCountEvent());
          }
        });
  }

  Future<void> _onLoadUnseenCount(
    LoadUnseenCountEvent event,
    Emitter<LikesState> emit,
  ) async {
    try {
      final unseenCount = await _getUnseenCount();
      final currentState = state;
      if (currentState is LikesLoaded) {
        emit(currentState.copyWith(unseenCount: unseenCount));
      } else {
        emit(
          LikesLoaded(
            entries: const [],
            totalCount: 0,
            unseenCount: unseenCount,
          ),
        );
      }
      _socketInit();
    } catch (e) {
      log('Error loading unseen likes count: $e', name: _logTag);
    }
  }

  Future<void> _onLoadReceivedLikes(
    LoadReceivedLikesEvent event,
    Emitter<LikesState> emit,
  ) async {
    final currentState = state;
    final existingEntries = event.refresh
        ? <LikesYouEntryEntity>[]
        : (currentState is LikesLoaded
              ? currentState.entries
              : <LikesYouEntryEntity>[]);

    if (currentState is LikesLoaded) {
      emit(currentState.copyWith(loadingEntries: true));
    }

    try {
      final result = await _getReceivedLikes(offset: existingEntries.length);
      emit(
        LikesLoaded(
          entries: [...existingEntries, ...result.entries],
          totalCount: result.totalCount,
          unseenCount: result.unseenCount,
        ),
      );
      _socketInit();
    } catch (e) {
      log('Error loading received likes: $e', name: _logTag);
      if (currentState is LikesLoaded) {
        emit(currentState.copyWith(loadingEntries: false));
      } else {
        emit(LikesError());
      }
    }
  }

  Future<void> _onLikeBack(
    LikeBackEvent event,
    Emitter<LikesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LikesLoaded) return;

    try {
      final response = await _likeBack(event.likerId);
      final updatedEntries = currentState.entries
          .where((e) => e.id != event.likerId)
          .toList();

      if (response['match'] == true) {
        final matchedUserJson = Map<String, dynamic>.from(
          response['matched_user'],
        );
        final matchUser = MatchesConnectionEntity(
          id: matchedUserJson['id'] as int,
          username: matchedUserJson['username'] as String,
          profilePictureMetaData: matchedUserJson['profile_picture'] as Map,
        );
        emit(
          currentState.copyWith(
            entries: updatedEntries,
            totalCount: currentState.totalCount - 1,
            matchUser: matchUser,
          ),
        );
      } else {
        emit(
          currentState.copyWith(
            entries: updatedEntries,
            totalCount: currentState.totalCount - 1,
          ),
        );
      }
    } catch (e) {
      log('Error liking back: $e', name: _logTag);
    }
  }

  Future<void> _onPassLike(
    PassLikeEvent event,
    Emitter<LikesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LikesLoaded) return;

    try {
      await _passLike(event.likerId);
      final updatedEntries = currentState.entries
          .where((e) => e.id != event.likerId)
          .toList();
      emit(
        currentState.copyWith(
          entries: updatedEntries,
          totalCount: currentState.totalCount - 1,
        ),
      );
    } catch (e) {
      log('Error passing like: $e', name: _logTag);
    }
  }

  void _onClearMatchUser(
    ClearLikesMatchUserEvent event,
    Emitter<LikesState> emit,
  ) {
    final currentState = state;
    if (currentState is LikesLoaded) {
      emit(currentState.copyWith(clearMatchUser: true));
    }
  }

  @override
  Future<void> close() {
    _connectionsSocketSubscription?.cancel();
    return super.close();
  }
}

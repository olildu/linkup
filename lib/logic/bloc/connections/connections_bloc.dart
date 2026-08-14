import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/data/models/live_chat_data_model.dart';
import 'package:linkup/data/websocket_services/chat_socket_services/chat_socket_service.dart';
import 'package:linkup/data/websocket_services/connections_socket_services/connections_socket_services.dart';
import 'package:linkup/domain/entities/chat_connection_entity.dart';
import 'package:linkup/domain/entities/matches_connection_entity.dart';
import 'package:linkup/domain/use_cases/match/cache_connections_use_case.dart';
import 'package:linkup/domain/use_cases/match/get_cached_connections_use_case.dart';
import 'package:linkup/domain/use_cases/match/get_connections_use_case.dart';
import 'package:linkup/domain/use_cases/user/block_user_use_case.dart';
import 'package:linkup/domain/use_cases/user/report_user_use_case.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';

part 'connections_event.dart';
part 'connections_state.dart';

class ConnectionsBloc extends Bloc<ConnectionsEvent, ConnectionsState> {
  StreamSubscription<String>? _chatSocketSubscription;
  StreamSubscription<String>? _connectionsSocketSubscription;

  final Map<int, Timer> _typingTimers = {};
  final String _logTag = 'ConnectionsBloc';

  final GetConnectionsUseCase _getConnections;
  final CacheConnectionsUseCase _cacheConnections;
  final GetCachedConnectionsUseCase _getCachedConnections;
  final BlockUserUseCase _blockUser;
  final ReportUserUseCase _reportUser;

  ConnectionsBloc({
    required GetConnectionsUseCase getConnectionsUseCase,
    required CacheConnectionsUseCase cacheConnectionsUseCase,
    required GetCachedConnectionsUseCase getCachedConnectionsUseCase,
    required BlockUserUseCase blockUserUseCase,
    required ReportUserUseCase reportUserUseCase,
  }) : _getConnections = getConnectionsUseCase,
       _cacheConnections = cacheConnectionsUseCase,
       _getCachedConnections = getCachedConnectionsUseCase,
       _blockUser = blockUserUseCase,
       _reportUser = reportUserUseCase,
       super(ConnectionsInitial()) {
    on<LoadConnectionsEvent>(_onLoad);
    on<ReportUserEvent>(_onReport);
    on<ReloadChatConnectionsEvent>(_onReload);
    on<MarkMessagesSeenEvent>(_onMarkSeen);
    on<BlockUserEvent>(_onBlock);
  }

  void _socketInit() {
    final int currentUserId = GetIt.instance<int>(instanceName: 'user_id');

    _chatSocketSubscription?.cancel();
    _chatSocketSubscription = ChatSocketServices.chatsMessageStream.listen((
      raw,
    ) {
      final currentState = state;
      if (currentState is! ConnectionsLoaded) return;

      final data = jsonDecode(raw);
      if (data['type'] != 'chats') return;

      final msg = Message.fromJson(data);
      final existingChat = currentState.chats
          .cast<ChatConnectionEntity?>()
          .firstWhere(
            (c) => c?.chatRoomId == msg.chatRoomId,
            orElse: () => null,
          );

      if (existingChat == null &&
          (data['chats_type'] == 'message' || data['chats_type'] == 'typing')) {
        add(LoadConnectionsEvent(showLoading: false));
        return;
      }

      if (data['chats_type'] == 'message') {
        _typingTimers[msg.chatRoomId]?.cancel();
        _typingTimers.remove(msg.chatRoomId);

        add(
          ReloadChatConnectionsEvent(
            liveChatData: LiveChatDataModel(
              from_: msg.from_,
              chatRoomId: msg.chatRoomId,
              message: msg.message,
              unseenCounterIncBy: msg.from_ == currentUserId ? 0 : 1,
              messageType: msg.media != null
                  ? MessageType.image
                  : MessageType.text,
              changeOrder: true,
            ),
          ),
        );
      } else if (data['chats_type'] == 'typing') {
        if (msg.from_ == currentUserId) return;

        add(
          ReloadChatConnectionsEvent(
            liveChatData: LiveChatDataModel(
              from_: msg.from_,
              chatRoomId: msg.chatRoomId,
              message: msg.message,
              unseenCounterIncBy: 0,
              messageType: MessageType.text,
            ),
          ),
        );

        _typingTimers[msg.chatRoomId]?.cancel();
        _typingTimers[msg.chatRoomId] = Timer(const Duration(seconds: 3), () {
          add(
            ReloadChatConnectionsEvent(
              liveChatData: LiveChatDataModel(
                from_: msg.from_,
                chatRoomId: msg.chatRoomId,
                message: existingChat?.message ?? '',
                unseenCounterIncBy: 0,
                messageType: existingChat?.messageType ?? MessageType.text,
              ),
            ),
          );
          _typingTimers.remove(msg.chatRoomId);
        });
      }
    });

    _connectionsSocketSubscription?.cancel();
    _connectionsSocketSubscription = ConnectionsSocketService
        .connectionsMessageStream
        .listen((raw) {
          if (state is! ConnectionsLoaded) return;
          final data = jsonDecode(raw);
          log('Connections socket data: $data', name: _logTag);
          if (data['type'] == 'connections-reload') {
            add(LoadConnectionsEvent(showLoading: false));
          }
        });
  }

  Future<void> _onLoad(
    LoadConnectionsEvent event,
    Emitter<ConnectionsState> emit,
  ) async {
    if (event.showLoading != false) emit(ConnectionsLoading());

    try {
      log('Loading connections...', name: _logTag);
      late List<ChatConnectionEntity> chats;
      late List<MatchesConnectionEntity> matches;

      try {
        final result = await _getConnections();
        chats = result.chats;
        matches = result.matches;
        await _cacheConnections(chats);
      } catch (_) {
        log('HTTP failed, using cache', name: _logTag);
        chats = await _getCachedConnections();
        matches = [];
      }

      _socketInit();
      emit(ConnectionsLoaded(matches: matches, chats: chats));
    } on Exception catch (e, st) {
      log('Error loading connections: $e', stackTrace: st, name: _logTag);
      emit(ConnectionsError());
    }
  }

  Future<void> _onReport(
    ReportUserEvent event,
    Emitter<ConnectionsState> emit,
  ) async {
    try {
      await _reportUser(event.userIdToReport, event.reason);
    } catch (e) {
      log('Error reporting user: $e', name: _logTag);
    }
  }

  Future<void> _onReload(
    ReloadChatConnectionsEvent event,
    Emitter<ConnectionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ConnectionsLoaded) return;

    final liveChatData = event.liveChatData;
    if (liveChatData == null) return;

    List<ChatConnectionEntity> updatedChats = List.from(currentState.chats);
    final index = updatedChats.indexWhere(
      (c) => c.chatRoomId == liveChatData.chatRoomId,
    );

    if (index != -1) {
      final old = updatedChats[index];
      updatedChats[index] = old.copyWith(
        message: liveChatData.message,
        unseenCounter: old.unseenCounter + liveChatData.unseenCounterIncBy,
        messageType: liveChatData.messageType,
      );

      if (liveChatData.changeOrder) {
        final latest = updatedChats.removeAt(index);
        updatedChats.insert(0, latest);
      }

      emit(currentState.copyWith(chats: updatedChats));
    }
  }

  void _onMarkSeen(
    MarkMessagesSeenEvent event,
    Emitter<ConnectionsState> emit,
  ) {
    final currentState = state;
    if (currentState is! ConnectionsLoaded) return;

    final updatedChats = List<ChatConnectionEntity>.from(currentState.chats);
    final index = updatedChats.indexWhere(
      (c) => c.chatRoomId == event.chatRoomId,
    );

    if (index != -1) {
      updatedChats[index] = updatedChats[index].copyWith(
        unseenCounter: event.decrementCounterTo,
      );
      emit(currentState.copyWith(chats: updatedChats));
    }
  }

  Future<void> _onBlock(
    BlockUserEvent event,
    Emitter<ConnectionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConnectionsLoaded) {
      final updatedChats = List<ChatConnectionEntity>.from(currentState.chats);
      final updatedMatches = List<MatchesConnectionEntity>.from(
        currentState.matches,
      );

      if (event.chatRoomId != null) {
        updatedChats.removeWhere((c) => c.chatRoomId == event.chatRoomId);
      }
      updatedMatches.removeWhere((m) => m.id == event.userIdToBlock);

      emit(currentState.copyWith(chats: updatedChats, matches: updatedMatches));
    }

    try {
      await _blockUser(event.userIdToBlock);
    } catch (e) {
      log('Error blocking user: $e', name: _logTag);
      add(LoadConnectionsEvent(showLoading: false));
    }
  }

  @override
  Future<void> close() {
    _chatSocketSubscription?.cancel();
    _connectionsSocketSubscription?.cancel();
    for (final t in _typingTimers.values) {
      t.cancel();
    }
    return super.close();
  }
}

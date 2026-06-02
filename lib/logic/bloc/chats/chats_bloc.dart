import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/data/models/chat_models/media_message_data_model.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/data/websocket_services/chat_socket_services/chat_socket_service.dart';
import 'package:linkup/domain/entities/media_message_entity.dart';
import 'package:linkup/domain/entities/message_entity.dart';
import 'package:linkup/domain/use_cases/chat/cache_message_use_case.dart';
import 'package:linkup/domain/use_cases/chat/fetch_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/get_cached_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/paginate_messages_use_case.dart';
import 'package:linkup/domain/use_cases/chat/save_unsent_message_use_case.dart';
import 'package:linkup/domain/use_cases/chat/upload_chat_media_use_case.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'chats_event.dart';
part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final int currentChatUserId;
  final int currentUserId;
  final int chatRoomId;

  final FetchMessagesUseCase _fetchMessages;
  final GetCachedMessagesUseCase _getCachedMessages;
  final CacheMessageUseCase _cacheMessage;
  final SaveUnsentMessageUseCase _saveUnsent;
  final UploadChatMediaUseCase _uploadMedia;
  final PaginateMessagesUseCase _paginate;

  StreamSubscription<String>? _messageSocketSubscription;
  StreamSubscription<bool>? _statusSubscription;
  Timer? _typingKillTimer;
  Timer? _typingTimer;
  bool _typingTimerActive = false;

  final String _logTag = 'ChatsBloc';

  ChatsBloc({
    required this.currentChatUserId,
    required this.currentUserId,
    required this.chatRoomId,
    required FetchMessagesUseCase fetchMessagesUseCase,
    required GetCachedMessagesUseCase getCachedMessagesUseCase,
    required CacheMessageUseCase cacheMessageUseCase,
    required SaveUnsentMessageUseCase saveUnsentMessageUseCase,
    required UploadChatMediaUseCase uploadChatMediaUseCase,
    required PaginateMessagesUseCase paginateMessagesUseCase,
  })  : _fetchMessages = fetchMessagesUseCase,
        _getCachedMessages = getCachedMessagesUseCase,
        _cacheMessage = cacheMessageUseCase,
        _saveUnsent = saveUnsentMessageUseCase,
        _uploadMedia = uploadChatMediaUseCase,
        _paginate = paginateMessagesUseCase,
        super(ChatsInitial()) {
    on<StartChatsEvent>(_onStartChats);
    on<SendMessageEvent>(_onSendMessage);
    on<NewMessageEvent>(_onNewMessage);
    on<MarkMessageAsSeenEvent>(_onMarkSeen);
    on<SeenEvent>(_onSeenEvent);
    on<TypingEvent>(_onTypingEvent);
    on<TypingTimeoutEvent>(_onTypingTimeout);
    on<SendTypingEvent>(_onSendTyping);
    on<UploadMediaChatEvent>(_onUploadMediaChat);
    on<PaginateAddMessagesEvent>(_onPaginateAddMessages);
    on<_ClearSocketDisconnectedFlagEvent>(_onClearSocketDisconnectedFlag);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  MessageEntity _messageToEntity(Message m) => MessageEntity(
        id: m.id,
        message: m.message,
        replyID: m.replyID,
        to: m.to,
        from_: m.from_,
        chatRoomId: m.chatRoomId,
        isSeen: m.isSeen,
        isSent: m.isSent,
        timestamp: m.timestamp,
        media: m.media == null
            ? null
            : MediaMessageEntity(
                fileKey: m.media!.fileKey,
                mediaType: m.media!.mediaType,
                blurhashText: m.media!.blurhashText,
                metadata: m.media!.metadata,
              ),
      );

  Message _entityToMessage(MessageEntity e) => Message(
        id: e.id,
        message: e.message,
        replyID: e.replyID,
        to: e.to,
        from_: e.from_,
        chatRoomId: e.chatRoomId,
        isSeen: e.isSeen,
        isSent: e.isSent,
        timestamp: e.timestamp,
        media: e.media == null
            ? null
            : MediaMessageData(
                fileKey: e.media!.fileKey,
                mediaType: e.media!.mediaType,
                blurhashText: e.media!.blurhashText,
                metadata: e.media!.metadata,
              ),
      );

  void _startSocketListeners() {
    _messageSocketSubscription?.cancel();
    _messageSocketSubscription = ChatSocketServices.chatsMessageStream.listen((raw) {
      log('Raw socket data: $raw', name: _logTag);
      final data = jsonDecode(raw);
      if (data['type'] == 'chats') {
        switch (data['chats_type']) {
          case 'message':
            add(NewMessageEvent(data));
            break;
          case 'typing':
            add(TypingEvent(data));
            break;
          case 'seen':
            add(SeenEvent(data));
            break;
        }
      }
    });

    _statusSubscription?.cancel();
    _statusSubscription = ChatSocketServices.chatsConnectionStatusStream.listen((connected) {
      log('Connection status: $connected', name: _logTag);
      if (connected) add(StartChatsEvent(showLoading: false));
    });
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  Future<void> _onStartChats(StartChatsEvent event, Emitter<ChatsState> emit) async {
    if (!event.showLoading) emit(ChatsLoading());
    try {
      _startSocketListeners();

      List<MessageEntity> entities;
      try {
        entities = await _fetchMessages(chatRoomId);
      } catch (_) {
        log('No internet, using cache', name: _logTag);
        entities = await _getCachedMessages(chatRoomId);
      }

      final messages = entities.map(_entityToMessage).toList();

      final first20 = entities.sublist(0, entities.length >= 20 ? 20 : entities.length);
      for (final e in first20) {
        await _cacheMessage(e);
      }

      log('Chat initialised', name: _logTag);
      emit(ChatsLoaded(messages: messages, isSocketConnected: ChatSocketServices.chatsIsConnected));
    } catch (e, st) {
      log('StartChatsEvent error', error: e, stackTrace: st, name: _logTag);
      emit(ChatsError());
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatsState> emit) async {
    try {
      final message = event.message;
      final currentState = state;

      if (currentState is! ChatsLoaded) {
        emit(ChatsLoaded(messages: [message]));
        return;
      }

      final isConnected = ChatSocketServices.chatsIsConnected;
      final outgoing = isConnected ? message : message.copyWith(isSent: false);
      final updated = List<Message>.from(currentState.messages)..add(outgoing);

      emit(currentState.copyWith(messages: updated, otherUserSeenMsg: false));

      if (isConnected) {
        ChatSocketServices.instance().sendMessage(message.toJson());
      } else {
        add(_ClearSocketDisconnectedFlagEvent(message: outgoing));
      }

      await _cacheMessage(_messageToEntity(outgoing));
    } catch (e, st) {
      log('SendMessageEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  void _onNewMessage(NewMessageEvent event, Emitter<ChatsState> emit) {
    try {
      final message = Message.fromJson(event.message);
      final currentState = state;

      if (currentState is ChatsLoaded) {
        log('Msg: from ${message.from_} vs $currentChatUserId | to ${message.to} vs $currentUserId', name: _logTag);
        if (message.to == currentUserId && message.from_ == currentChatUserId) {
          final updated = List<Message>.from(currentState.messages)..add(message);
          emit(currentState.copyWith(messages: updated, isTyping: false));
        }
      } else {
        emit(ChatsLoaded(messages: [message]));
      }
    } catch (e, st) {
      log('NewMessageEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  void _onMarkSeen(MarkMessageAsSeenEvent event, Emitter<ChatsState> emit) {
    try {
      final currentState = state;
      if (currentState is! ChatsLoaded) return;

      final index = currentState.messages.lastIndexWhere((m) => m.id == event.messageId);
      if (index == -1 || currentState.messages[index].isSeen) return;

      final msgs = List<Message>.from(currentState.messages);
      msgs[index] = msgs[index].copyWith(isSeen: true);

      ChatSocketServices.instance().sendMessage({
        'type': 'chats',
        'chats_type': 'seen',
        'to': currentChatUserId,
        'from_': currentUserId,
        'chat_room_id': chatRoomId,
        'message_id': event.messageId,
      });

      emit(currentState.copyWith(messages: msgs));
    } catch (e, st) {
      log('MarkMessageAsSeenEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  Future<void> _onSeenEvent(SeenEvent event, Emitter<ChatsState> emit) async {
    try {
      if (event.message['from_'] != currentChatUserId) return;
      final currentState = state;
      if (currentState is ChatsLoaded) {
        emit(currentState.copyWith(otherUserSeenMsg: true));
      }
    } catch (e, st) {
      log('SeenEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  void _onTypingEvent(TypingEvent event, Emitter<ChatsState> emit) {
    try {
      final fromUserId = event.message['from_'] as int;
      if (fromUserId != currentChatUserId) return;
      final currentState = state;
      if (currentState is ChatsLoaded) {
        emit(currentState.copyWith(isTyping: true, typingUserId: fromUserId));
        _typingKillTimer?.cancel();
        _typingKillTimer = Timer(const Duration(seconds: 3), () {
          add(TypingTimeoutEvent(userId: fromUserId));
        });
      }
    } catch (e, st) {
      log('TypingEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  void _onTypingTimeout(TypingTimeoutEvent event, Emitter<ChatsState> emit) {
    final currentState = state;
    if (currentState is ChatsLoaded && currentState.typingUserId == event.userId) {
      emit(currentState.copyWith(isTyping: false, typingUserId: null));
    }
  }

  void _onSendTyping(SendTypingEvent event, Emitter<ChatsState> emit) {
    try {
      if (state is ChatsLoaded && !_typingTimerActive) {
        ChatSocketServices.instance().sendMessage({
          'type': 'chats',
          'chats_type': 'typing',
          'to': event.currentChatUserId,
          'from_': currentUserId,
          'chat_room_id': chatRoomId,
        });
        _typingTimerActive = true;
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(milliseconds: 1500), () {
          _typingTimerActive = false;
        });
      }
    } catch (e, st) {
      log('SendTypingEvent error', error: e, stackTrace: st, name: _logTag);
    }
  }

  Future<void> _onUploadMediaChat(UploadMediaChatEvent event, Emitter<ChatsState> emit) async {
    try {
      final currentState = state;
      if (currentState is! ChatsLoaded) return;

      final metadata = await _uploadMedia(event.file, event.mediaType);
      log('Media uploaded', name: _logTag);

      final message = Message(
        id: const Uuid().v4(),
        message: '',
        to: currentChatUserId,
        timestamp: DateTime.now(),
        from_: currentUserId,
        chatRoomId: chatRoomId,
        media: MediaMessageData(
          fileKey: metadata['file_key'] as String,
          mediaType: MessageType.image,
          blurhashText: '',
          metadata: metadata['metadata'] as Map<String, dynamic>,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      add(SendMessageEvent(message: message));
      emit(currentState);
    } catch (e, st) {
      log('uploadMediaChatEvent error', error: e, stackTrace: st, name: _logTag);
      emit(ChatsError());
    }
  }

  Future<void> _onPaginateAddMessages(
    PaginateAddMessagesEvent event,
    Emitter<ChatsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatsLoaded) return;

    emit(currentState.copyWith(isFetchingPaginatedMessages: true));

    final entities = await _paginate(
      chatRoomId: chatRoomId,
      lastMessageId: event.lastMessageID,
      lastMessageTimeStamp: event.lastMessageTimeStamp,
    );

    final older = entities.map(_entityToMessage).toList();
    emit(currentState.copyWith(
      messages: [...older, ...currentState.messages],
      isFetchingPaginatedMessages: false,
    ));
  }

  Future<void> _onClearSocketDisconnectedFlag(
    _ClearSocketDisconnectedFlagEvent event,
    Emitter<ChatsState> emit,
  ) async {
    await _saveUnsent(_messageToEntity(event.message));
  }

  @override
  Future<void> close() {
    _messageSocketSubscription?.cancel();
    _statusSubscription?.cancel();
    _typingTimer?.cancel();
    _typingKillTimer?.cancel();
    return super.close();
  }
}

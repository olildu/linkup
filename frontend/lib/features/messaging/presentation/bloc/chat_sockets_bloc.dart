import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:linkup/features/messaging/data/chat_socket_service.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_by_message_id_use_case.dart';
import 'package:linkup/features/messaging/domain/get_unsent_messages_use_case.dart';
import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';
import 'package:linkup/features/messaging/data/models/media_message_data_model.dart';
import 'package:meta/meta.dart';

part 'chat_sockets_event.dart';
part 'chat_sockets_state.dart';

class ChatSocketsBloc extends Bloc<ChatSocketsEvent, ChatSocketsState> {
  StreamSubscription<bool>? _statusSubscription;
  final String _logTag = 'ChatSocketsBloc';

  final GetUnsentMessagesUseCase _getUnsent;
  final DeleteUnsentByMessageIdUseCase _deleteUnsentByMsgId;
  final ChatSocketServices _chatSocket;

  ChatSocketsBloc({
    required GetUnsentMessagesUseCase getUnsentMessagesUseCase,
    required DeleteUnsentByMessageIdUseCase deleteUnsentByMessageIdUseCase,
    ChatSocketServices? chatSocket,
  }) : _getUnsent = getUnsentMessagesUseCase,
       _deleteUnsentByMsgId = deleteUnsentByMessageIdUseCase,
       _chatSocket = chatSocket ?? ChatSocketServices.instance(),
       super(ChatSocketsInitial()) {
    on<LoadChatSocketsEvent>((event, emit) async {
      emit(ChatSocketsConnecting());
      try {
        await _chatSocket.connect();

        _statusSubscription?.cancel();
        _statusSubscription = _chatSocket.connectionStatusStream
            .listen((connected) async {
              log('WebSocket connected: $connected', name: _logTag);
              if (!connected) return;

              final unsent = await _getUnsent();
              for (final entity in unsent) {
                try {
                  final message = _entityToModel(entity);
                  _chatSocket.sendMessage(message.toJson());
                  await _deleteUnsentByMsgId(entity.id);
                } catch (e) {
                  log('Failed to resend unsent message: $e', name: _logTag);
                }
              }
            });

        emit(ChatSocketsConnected());
      } catch (e) {
        log('ChatSockets error: $e', name: _logTag);
        emit(ChatSocketsError());
      }
    });
  }

  Message _entityToModel(MessageEntity e) => Message(
    id: e.id,
    message: e.message,
    to: e.to,
    from_: e.from_,
    chatRoomId: e.chatRoomId,
    isSeen: e.isSeen,
    isSent: e.isSent,
    timestamp: e.timestamp,
    replyID: e.replyID,
    media: e.media == null
        ? null
        : MediaMessageData(
            fileKey: e.media!.fileKey,
            mediaType: e.media!.mediaType,
            blurhashText: e.media!.blurhashText,
            metadata: e.media!.metadata,
          ),
  );

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}

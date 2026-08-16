import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class PaginateMessagesUseCase {
  final ChatRepository _repository;
  const PaginateMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call({
    required int chatRoomId,
    required String lastMessageId,
    required DateTime lastMessageTimeStamp,
  }) => _repository.fetchPaginatedMessages(
    chatRoomId: chatRoomId,
    lastMessageId: lastMessageId,
    lastMessageTimeStamp: lastMessageTimeStamp,
  );
}

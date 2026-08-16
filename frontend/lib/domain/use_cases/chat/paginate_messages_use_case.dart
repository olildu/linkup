import 'package:linkup/domain/entities/message_entity.dart';
import 'package:linkup/domain/repositories/chat_repository.dart';

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

import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class FetchMessagesUseCase {
  final ChatRepository _repository;
  const FetchMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call(int chatRoomId) =>
      _repository.fetchMessages(chatRoomId);
}

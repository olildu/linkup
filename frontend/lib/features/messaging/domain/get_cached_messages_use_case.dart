import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class GetCachedMessagesUseCase {
  final ChatRepository _repository;
  const GetCachedMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call(int chatRoomId) =>
      _repository.getCachedMessages(chatRoomId);
}

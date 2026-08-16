import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class GetUnsentMessagesUseCase {
  final ChatRepository _repository;
  const GetUnsentMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call() => _repository.getUnsentMessages();
}

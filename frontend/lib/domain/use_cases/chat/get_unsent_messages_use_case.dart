import 'package:linkup/domain/entities/message_entity.dart';
import 'package:linkup/domain/repositories/chat_repository.dart';

class GetUnsentMessagesUseCase {
  final ChatRepository _repository;
  const GetUnsentMessagesUseCase(this._repository);

  Future<List<MessageEntity>> call() => _repository.getUnsentMessages();
}

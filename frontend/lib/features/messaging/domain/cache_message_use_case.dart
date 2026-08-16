import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class CacheMessageUseCase {
  final ChatRepository _repository;
  const CacheMessageUseCase(this._repository);

  Future<void> call(MessageEntity message, {int maxCount = 20}) =>
      _repository.cacheMessage(message, maxCount);
}

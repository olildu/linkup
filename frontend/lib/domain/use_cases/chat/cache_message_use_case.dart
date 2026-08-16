import 'package:linkup/domain/entities/message_entity.dart';
import 'package:linkup/domain/repositories/chat_repository.dart';

class CacheMessageUseCase {
  final ChatRepository _repository;
  const CacheMessageUseCase(this._repository);

  Future<void> call(MessageEntity message, {int maxCount = 20}) =>
      _repository.cacheMessage(message, maxCount);
}

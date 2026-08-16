import 'package:linkup/features/messaging/domain/message_entity.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class SaveUnsentMessageUseCase {
  final ChatRepository _repository;
  const SaveUnsentMessageUseCase(this._repository);

  Future<void> call(MessageEntity message) =>
      _repository.saveUnsentMessage(message);
}

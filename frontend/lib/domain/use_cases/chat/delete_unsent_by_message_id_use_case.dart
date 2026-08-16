import 'package:linkup/domain/repositories/chat_repository.dart';

class DeleteUnsentByMessageIdUseCase {
  final ChatRepository _repository;
  const DeleteUnsentByMessageIdUseCase(this._repository);

  Future<void> call(String messageId) =>
      _repository.deleteUnsentMessageByMsgId(messageId);
}

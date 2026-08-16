import 'package:linkup/features/messaging/domain/chat_repository.dart';

class DeleteUnsentMessageUseCase {
  final ChatRepository _repository;
  const DeleteUnsentMessageUseCase(this._repository);

  Future<void> call(int isarId) => _repository.deleteUnsentMessage(isarId);
}

import 'package:linkup/features/messaging/domain/chat_repository.dart';

class StartChatUseCase {
  final ChatRepository _repository;
  const StartChatUseCase(this._repository);

  Future<Map<String, dynamic>> call(int chatUserId) =>
      _repository.startChat(chatUserId);
}

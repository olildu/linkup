import 'package:linkup/domain/entities/chat_connection_entity.dart';
import 'package:linkup/domain/repositories/match_repository.dart';

class CacheConnectionsUseCase {
  final MatchRepository _repository;
  const CacheConnectionsUseCase(this._repository);

  Future<void> call(List<ChatConnectionEntity> chats) =>
      _repository.cacheConnections(chats);
}

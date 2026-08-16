import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';

class CacheConnectionsUseCase {
  final MatchRepository _repository;
  const CacheConnectionsUseCase(this._repository);

  Future<void> call(List<ChatConnectionEntity> chats) =>
      _repository.cacheConnections(chats);
}

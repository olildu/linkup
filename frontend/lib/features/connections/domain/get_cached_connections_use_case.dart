import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';

class GetCachedConnectionsUseCase {
  final MatchRepository _repository;
  const GetCachedConnectionsUseCase(this._repository);

  Future<List<ChatConnectionEntity>> call() =>
      _repository.getCachedConnections();
}

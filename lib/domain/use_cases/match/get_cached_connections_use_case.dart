import 'package:linkup/domain/entities/chat_connection_entity.dart';
import 'package:linkup/domain/repositories/match_repository.dart';

class GetCachedConnectionsUseCase {
  final MatchRepository _repository;
  const GetCachedConnectionsUseCase(this._repository);

  Future<List<ChatConnectionEntity>> call() => _repository.getCachedConnections();
}

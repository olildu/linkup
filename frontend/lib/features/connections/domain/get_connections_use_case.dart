import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';

class GetConnectionsUseCase {
  final MatchRepository _repository;
  const GetConnectionsUseCase(this._repository);

  Future<
    ({List<MatchesConnectionEntity> matches, List<ChatConnectionEntity> chats})
  >
  call() => _repository.getConnections();
}

import 'package:linkup/domain/entities/chat_connection_entity.dart';
import 'package:linkup/domain/entities/matches_connection_entity.dart';
import 'package:linkup/domain/repositories/match_repository.dart';

class GetConnectionsUseCase {
  final MatchRepository _repository;
  const GetConnectionsUseCase(this._repository);

  Future<({List<MatchesConnectionEntity> matches, List<ChatConnectionEntity> chats})> call() =>
      _repository.getConnections();
}

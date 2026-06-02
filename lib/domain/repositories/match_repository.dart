import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/domain/entities/chat_connection_entity.dart';
import 'package:linkup/domain/entities/match_candidate_entity.dart';
import 'package:linkup/domain/entities/matches_connection_entity.dart';

abstract class MatchRepository {
  Future<List<MatchCandidateEntity>> getMatchUsers();
  Future<Map<String, dynamic>> swipe(int likedId, CardSwiperDirection direction);
  Future<({List<MatchesConnectionEntity> matches, List<ChatConnectionEntity> chats})> getConnections();
  Future<void> cacheConnections(List<ChatConnectionEntity> chats);
  Future<List<ChatConnectionEntity>> getCachedConnections();
}

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/features/connections/data/chat_local_datasource.dart';
import 'package:linkup/features/discovery/data/match_remote_datasource.dart';
import 'package:linkup/features/discovery/data/swipe_remote_datasource.dart';
import 'package:linkup/features/connections/data/chats_connection_model.dart';
import 'package:linkup/features/connections/domain/chat_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/core/entities/matches_connection_entity.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDatasource _matchDatasource;
  final SwipeRemoteDatasource _swipeDatasource;
  final ChatLocalDatasource _chatLocalDatasource;

  const MatchRepositoryImpl({
    required MatchRemoteDatasource matchDatasource,
    required SwipeRemoteDatasource swipeDatasource,
    required ChatLocalDatasource chatLocalDatasource,
  }) : _matchDatasource = matchDatasource,
       _swipeDatasource = swipeDatasource,
       _chatLocalDatasource = chatLocalDatasource;

  @override
  Future<({List<MatchCandidateEntity> matches, int? swipesRemaining})>
  getMatchUsers({bool refresh = false}) async {
    final result = await _matchDatasource.getMatchUsers(refresh: refresh);
    return (
      matches: result.matches
          .map(
            (m) => MatchCandidateEntity(
              id: m.id,
              username: m.username,
              gender: m.gender,
              universityId: m.universityId,
              profilePictureMetaData: m.profilePictureMetaData,
              dob: m.dob,
              universityMajor: m.universityMajor,
              universityYear: m.universityYear,
              photos: m.photos,
              about: m.about,
              currentlyStaying: m.currentlyStaying,
              hometown: m.hometown,
              height: m.height,
              weight: m.weight,
              religion: m.religion,
              smokingInfo: m.smokingInfo,
              drinkingInfo: m.drinkingInfo,
              lookingFor: m.lookingFor,
            ),
          )
          .toList(),
      swipesRemaining: result.swipesRemaining,
    );
  }

  @override
  Future<Map<String, dynamic>> swipe(
    int likedId,
    CardSwiperDirection direction,
  ) => _swipeDatasource.swipe(likedId, direction);

  @override
  Future<
    ({List<MatchesConnectionEntity> matches, List<ChatConnectionEntity> chats})
  >
  getConnections() async {
    final result = await _matchDatasource.getConnections();
    return (
      matches: result.matches
          .map(
            (m) => MatchesConnectionEntity(
              id: m.id,
              username: m.username,
              profilePictureMetaData: m.profilePictureMetaData,
            ),
          )
          .toList(),
      chats: result.chats.map(_chatToEntity).toList(),
    );
  }

  @override
  Future<void> cacheConnections(List<ChatConnectionEntity> chats) =>
      _chatLocalDatasource.replaceAll(chats.map(_entityToChat).toList());

  @override
  Future<List<ChatConnectionEntity>> getCachedConnections() async {
    final models = await _chatLocalDatasource.getAll();
    return models.map(_chatToEntity).toList();
  }

  ChatConnectionEntity _chatToEntity(ChatsConnectionModel m) =>
      ChatConnectionEntity(
        id: m.id,
        username: m.username,
        profilePictureMetaData: m.profilePictureMetaData,
        chatRoomId: m.chatRoomId,
        unseenCounter: m.unseenCounter,
        message: m.message,
        messageType: m.messageType,
        isDeleted: m.isDeleted,
      );

  ChatsConnectionModel _entityToChat(ChatConnectionEntity e) =>
      ChatsConnectionModel(
        id: e.id,
        username: e.username,
        profilePictureMetaData: e.profilePictureMetaData,
        chatRoomId: e.chatRoomId,
        unseenCounter: e.unseenCounter,
        message: e.message,
        messageType: e.messageType,
        isDeleted: e.isDeleted,
      );
}

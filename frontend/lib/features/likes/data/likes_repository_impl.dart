import 'package:linkup/features/likes/data/likes_remote_datasource.dart';
import 'package:linkup/features/likes/data/likes_you_entry_model.dart';
import 'package:linkup/features/likes/domain/likes_you_entry_entity.dart';
import 'package:linkup/features/discovery/domain/match_candidate_entity.dart';
import 'package:linkup/features/likes/domain/likes_repository.dart';

class LikesRepositoryImpl implements LikesRepository {
  final LikesRemoteDatasource _likesDatasource;

  const LikesRepositoryImpl({required LikesRemoteDatasource likesDatasource})
    : _likesDatasource = likesDatasource;

  @override
  Future<({List<LikesYouEntryEntity> entries, int totalCount, int unseenCount})>
  getReceivedLikes({int offset = 0}) async {
    final result = await _likesDatasource.getReceivedLikes(offset: offset);
    return (
      entries: result.entries.map(_entryToEntity).toList(),
      totalCount: result.totalCount,
      unseenCount: result.unseenCount,
    );
  }

  @override
  Future<int> getLikesCount() => _likesDatasource.getLikesCount();

  @override
  Future<Map<String, dynamic>> likeBack(int likerId) =>
      _likesDatasource.likeBack(likerId);

  @override
  Future<void> passLike(int likerId) => _likesDatasource.passLike(likerId);

  LikesYouEntryEntity _entryToEntity(LikesYouEntryModel m) =>
      LikesYouEntryEntity(
        id: m.id,
        revealed: m.revealed,
        profile: m.profile != null
            ? MatchCandidateEntity(
                id: m.profile!.id,
                username: m.profile!.username,
                gender: m.profile!.gender,
                universityId: m.profile!.universityId,
                profilePictureMetaData: m.profile!.profilePictureMetaData,
                dob: m.profile!.dob,
                universityMajor: m.profile!.universityMajor,
                universityYear: m.profile!.universityYear,
                // CandidateDetailBuilder indexes into photos[0] and slices the
                // rest — an empty list from the backend would crash it, so
                // fall back to the profile picture as the sole photo.
                photos: m.profile!.photos.isEmpty
                    ? [m.profile!.profilePictureMetaData]
                    : m.profile!.photos,
                about: m.profile!.about,
                currentlyStaying: m.profile!.currentlyStaying,
                hometown: m.profile!.hometown,
                height: m.profile!.height,
                weight: m.profile!.weight,
                religion: m.profile!.religion,
                smokingInfo: m.profile!.smokingInfo,
                drinkingInfo: m.profile!.drinkingInfo,
                lookingFor: m.profile!.lookingFor,
              )
            : null,
        firstPhoto: m.firstPhoto,
      );
}

import 'package:linkup/domain/entities/likes_you_entry_entity.dart';

abstract class LikesRepository {
  Future<({List<LikesYouEntryEntity> entries, int totalCount, int unseenCount})>
  getReceivedLikes({int offset = 0});
  Future<int> getLikesCount();
  Future<Map<String, dynamic>> likeBack(int likerId);
  Future<void> passLike(int likerId);
}

import 'package:linkup/features/likes/domain/likes_you_entry_entity.dart';
import 'package:linkup/features/likes/domain/likes_repository.dart';

class GetReceivedLikesUseCase {
  final LikesRepository _repository;
  const GetReceivedLikesUseCase(this._repository);

  Future<({List<LikesYouEntryEntity> entries, int totalCount, int unseenCount})>
  call({int offset = 0}) => _repository.getReceivedLikes(offset: offset);
}

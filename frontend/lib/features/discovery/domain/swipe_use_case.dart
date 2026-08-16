import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/features/discovery/domain/match_repository.dart';

class SwipeUseCase {
  final MatchRepository _repository;
  const SwipeUseCase(this._repository);

  Future<Map<String, dynamic>> call(
    int likedId,
    CardSwiperDirection direction,
  ) => _repository.swipe(likedId, direction);
}

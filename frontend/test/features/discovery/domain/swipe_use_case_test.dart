import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/features/discovery/domain/swipe_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockMatchRepository repository;
  late SwipeUseCase useCase;

  setUp(() {
    repository = MockMatchRepository();
    useCase = SwipeUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.swipe(7, CardSwiperDirection.right)).thenAnswer((_) async => {'match': true});

    expect(await useCase(7, CardSwiperDirection.right), {'match': true});

    verify(() => repository.swipe(7, CardSwiperDirection.right)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.swipe(7, CardSwiperDirection.left)).thenThrow(Exception('boom'));

    expect(() => useCase(7, CardSwiperDirection.left), throwsException);
  });
}

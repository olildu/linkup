import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/domain/get_likes_count_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockLikesRepository repository;
  late GetLikesCountUseCase useCase;

  setUp(() {
    repository = MockLikesRepository();
    useCase = GetLikesCountUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getLikesCount()).thenAnswer((_) async => 3);

    expect(await useCase(), 3);

    verify(() => repository.getLikesCount()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getLikesCount()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

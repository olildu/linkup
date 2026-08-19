import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/domain/pass_like_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockLikesRepository repository;
  late PassLikeUseCase useCase;

  setUp(() {
    repository = MockLikesRepository();
    useCase = PassLikeUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.passLike(5)).thenAnswer((_) async {});

    await useCase(5);

    verify(() => repository.passLike(5)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.passLike(5)).thenThrow(Exception('boom'));

    expect(() => useCase(5), throwsException);
  });
}

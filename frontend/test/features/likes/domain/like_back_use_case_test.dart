import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/domain/like_back_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockLikesRepository repository;
  late LikeBackUseCase useCase;

  setUp(() {
    repository = MockLikesRepository();
    useCase = LikeBackUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.likeBack(5)).thenAnswer((_) async => {'matched': true});

    expect(await useCase(5), {'matched': true});

    verify(() => repository.likeBack(5)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.likeBack(5)).thenThrow(Exception('boom'));

    expect(() => useCase(5), throwsException);
  });
}

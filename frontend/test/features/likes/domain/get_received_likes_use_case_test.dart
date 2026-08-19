import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/domain/get_received_likes_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockLikesRepository repository;
  late GetReceivedLikesUseCase useCase;

  final result = (entries: [makeLikesEntry()], totalCount: 1, unseenCount: 1);
  setUp(() {
    repository = MockLikesRepository();
    useCase = GetReceivedLikesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getReceivedLikes(offset: 20)).thenAnswer((_) async => result);

    expect(await useCase(offset: 20), result);

    verify(() => repository.getReceivedLikes(offset: 20)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getReceivedLikes(offset: 0)).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

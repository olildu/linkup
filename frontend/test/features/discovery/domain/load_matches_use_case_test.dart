import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/domain/load_matches_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockMatchRepository repository;
  late LoadMatchesUseCase useCase;

  final result = (matches: [makeCandidate()], swipesRemaining: 5);
  setUp(() {
    repository = MockMatchRepository();
    useCase = LoadMatchesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getMatchUsers(refresh: true)).thenAnswer((_) async => result);

    expect(await useCase(refresh: true), result);

    verify(() => repository.getMatchUsers(refresh: true)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getMatchUsers(refresh: false)).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

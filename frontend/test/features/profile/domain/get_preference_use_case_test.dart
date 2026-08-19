import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/domain/get_preference_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockUserRepository repository;
  late GetPreferenceUseCase useCase;

  final preference = makePreference();
  setUp(() {
    repository = MockUserRepository();
    useCase = GetPreferenceUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getPreference()).thenAnswer((_) async => preference);

    expect(await useCase(), preference);

    verify(() => repository.getPreference()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getPreference()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

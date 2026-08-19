import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/domain/update_preference_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockUserRepository repository;
  late UpdatePreferenceUseCase useCase;

  final preference = makePreference();
  setUp(() {
    repository = MockUserRepository();
    useCase = UpdatePreferenceUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.updatePreference(preference)).thenAnswer((_) async {});

    await useCase(preference);

    verify(() => repository.updatePreference(preference)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.updatePreference(preference)).thenThrow(Exception('boom'));

    expect(() => useCase(preference), throwsException);
  });
}

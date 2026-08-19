import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/domain/get_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockUserRepository repository;
  late GetProfileUseCase useCase;

  final user = makeUser();
  setUp(() {
    repository = MockUserRepository();
    useCase = GetProfileUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getProfile()).thenAnswer((_) async => user);

    expect(await useCase(), user);

    verify(() => repository.getProfile()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getProfile()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

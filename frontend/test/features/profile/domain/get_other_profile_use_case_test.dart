import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/domain/get_other_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockUserRepository repository;
  late GetOtherProfileUseCase useCase;

  final candidate = makeCandidate();
  setUp(() {
    repository = MockUserRepository();
    useCase = GetOtherProfileUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getOtherProfile(7)).thenAnswer((_) async => candidate);

    expect(await useCase(7), candidate);

    verify(() => repository.getOtherProfile(7)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getOtherProfile(7)).thenThrow(Exception('boom'));

    expect(() => useCase(7), throwsException);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.logout()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.logout()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.logout()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

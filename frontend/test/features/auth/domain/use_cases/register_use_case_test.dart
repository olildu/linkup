import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/register_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late RegisterUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = RegisterUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.register('hash', 'pw')).thenAnswer((_) async {});

    await useCase('hash', 'pw');

    verify(() => repository.register('hash', 'pw')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.register('hash', 'pw')).thenThrow(Exception('boom'));

    expect(() => useCase('hash', 'pw'), throwsException);
  });
}

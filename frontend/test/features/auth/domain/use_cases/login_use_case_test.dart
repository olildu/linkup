import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/login_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.login('a@b.com', 'pw')).thenAnswer((_) async {});

    await useCase('a@b.com', 'pw');

    verify(() => repository.login('a@b.com', 'pw')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.login('a@b.com', 'pw')).thenThrow(Exception('boom'));

    expect(() => useCase('a@b.com', 'pw'), throwsException);
  });
}

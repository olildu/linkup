import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late ResetPasswordUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = ResetPasswordUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.resetPassword('hash', 'pw')).thenAnswer((_) async {});

    await useCase('hash', 'pw');

    verify(() => repository.resetPassword('hash', 'pw')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.resetPassword('hash', 'pw')).thenThrow(Exception('boom'));

    expect(() => useCase('hash', 'pw'), throwsException);
  });
}

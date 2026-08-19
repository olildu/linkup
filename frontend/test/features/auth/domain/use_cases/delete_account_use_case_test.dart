import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/auth/domain/use_cases/delete_account_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;
  late DeleteAccountUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = DeleteAccountUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.deleteAccount()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.deleteAccount()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.deleteAccount()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/domain/block_user_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late BlockUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = BlockUserUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.blockUser(9)).thenAnswer((_) async {});

    await useCase(9);

    verify(() => repository.blockUser(9)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.blockUser(9)).thenThrow(Exception('boom'));

    expect(() => useCase(9), throwsException);
  });
}

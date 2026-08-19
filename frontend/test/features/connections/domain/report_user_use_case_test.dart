import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/connections/domain/report_user_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockUserRepository repository;
  late ReportUserUseCase useCase;

  setUp(() {
    repository = MockUserRepository();
    useCase = ReportUserUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.reportUser(9, 'spam')).thenAnswer((_) async {});

    await useCase(9, 'spam');

    verify(() => repository.reportUser(9, 'spam')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.reportUser(9, 'spam')).thenThrow(Exception('boom'));

    expect(() => useCase(9, 'spam'), throwsException);
  });
}

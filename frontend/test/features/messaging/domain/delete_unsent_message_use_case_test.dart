import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_message_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late DeleteUnsentMessageUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = DeleteUnsentMessageUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.deleteUnsentMessage(42)).thenAnswer((_) async {});

    await useCase(42);

    verify(() => repository.deleteUnsentMessage(42)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.deleteUnsentMessage(42)).thenThrow(Exception('boom'));

    expect(() => useCase(42), throwsException);
  });
}

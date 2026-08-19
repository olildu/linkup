import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/get_unsent_messages_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockChatRepository repository;
  late GetUnsentMessagesUseCase useCase;

  final messages = [makeMessage(isSent: false)];
  setUp(() {
    repository = MockChatRepository();
    useCase = GetUnsentMessagesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getUnsentMessages()).thenAnswer((_) async => messages);

    expect(await useCase(), messages);

    verify(() => repository.getUnsentMessages()).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getUnsentMessages()).thenThrow(Exception('boom'));

    expect(() => useCase(), throwsException);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/get_cached_messages_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockChatRepository repository;
  late GetCachedMessagesUseCase useCase;

  final messages = [makeMessage()];
  setUp(() {
    repository = MockChatRepository();
    useCase = GetCachedMessagesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.getCachedMessages(10)).thenAnswer((_) async => messages);

    expect(await useCase(10), messages);

    verify(() => repository.getCachedMessages(10)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.getCachedMessages(10)).thenThrow(Exception('boom'));

    expect(() => useCase(10), throwsException);
  });
}

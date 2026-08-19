import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/cache_message_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockChatRepository repository;
  late CacheMessageUseCase useCase;

  final message = makeMessage();
  setUp(() {
    repository = MockChatRepository();
    useCase = CacheMessageUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.cacheMessage(message, 5)).thenAnswer((_) async {});

    await useCase(message, maxCount: 5);

    verify(() => repository.cacheMessage(message, 5)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.cacheMessage(message, 20)).thenThrow(Exception('boom'));

    expect(() => useCase(message), throwsException);
  });
}

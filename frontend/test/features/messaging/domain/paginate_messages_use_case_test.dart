import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/paginate_messages_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockChatRepository repository;
  late PaginateMessagesUseCase useCase;

  final ts = DateTime(2026, 1, 1);
  final messages = [makeMessage()];
  setUp(() {
    repository = MockChatRepository();
    useCase = PaginateMessagesUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.fetchPaginatedMessages(chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts)).thenAnswer((_) async => messages);

    expect(await useCase(chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts), messages);

    verify(() => repository.fetchPaginatedMessages(chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.fetchPaginatedMessages(chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts)).thenThrow(Exception('boom'));

    expect(() => useCase(chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts), throwsException);
  });
}

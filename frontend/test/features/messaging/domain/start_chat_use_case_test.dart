import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/start_chat_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late StartChatUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = StartChatUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.startChat(2)).thenAnswer((_) async => {'chat_room_id': 10});

    expect(await useCase(2), {'chat_room_id': 10});

    verify(() => repository.startChat(2)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.startChat(2)).thenThrow(Exception('boom'));

    expect(() => useCase(2), throwsException);
  });
}

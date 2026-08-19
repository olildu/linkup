import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/save_unsent_message_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/fixtures.dart';

void main() {
  late MockChatRepository repository;
  late SaveUnsentMessageUseCase useCase;

  final message = makeMessage(isSent: false);
  setUp(() {
    repository = MockChatRepository();
    useCase = SaveUnsentMessageUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.saveUnsentMessage(message)).thenAnswer((_) async {});

    await useCase(message);

    verify(() => repository.saveUnsentMessage(message)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.saveUnsentMessage(message)).thenThrow(Exception('boom'));

    expect(() => useCase(message), throwsException);
  });
}

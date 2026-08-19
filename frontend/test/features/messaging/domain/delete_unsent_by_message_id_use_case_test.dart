import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/domain/delete_unsent_by_message_id_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late DeleteUnsentByMessageIdUseCase useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = DeleteUnsentByMessageIdUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.deleteUnsentMessageByMsgId('m1')).thenAnswer((_) async {});

    await useCase('m1');

    verify(() => repository.deleteUnsentMessageByMsgId('m1')).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.deleteUnsentMessageByMsgId('m1')).thenThrow(Exception('boom'));

    expect(() => useCase('m1'), throwsException);
  });
}

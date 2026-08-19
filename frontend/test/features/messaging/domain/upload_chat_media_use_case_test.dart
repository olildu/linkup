import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/domain/upload_chat_media_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockChatRepository repository;
  late UploadChatMediaUseCase useCase;

  final file = File('/tmp/pic.png');
  setUp(() {
    repository = MockChatRepository();
    useCase = UploadChatMediaUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.uploadChatMedia(file, MessageType.image)).thenAnswer((_) async => {'file_key': 'k'});

    expect(await useCase(file, MessageType.image), {'file_key': 'k'});

    verify(() => repository.uploadChatMedia(file, MessageType.image)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.uploadChatMedia(file, MessageType.voice)).thenThrow(Exception('boom'));

    expect(() => useCase(file, MessageType.voice), throwsException);
  });
}

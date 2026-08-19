import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/profile/domain/upload_pfp_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockMediaRepository repository;
  late UploadPfpUseCase useCase;

  final file = File('/tmp/pfp.png');
  setUp(() {
    repository = MockMediaRepository();
    useCase = UploadPfpUseCase(repository);
  });

  test('delegates to the repository and returns its result', () async {
    when(() => repository.uploadPfp(file, MessageType.image)).thenAnswer((_) async => {'ok': true});

    expect(await useCase(file, MessageType.image), {'ok': true});

    verify(() => repository.uploadPfp(file, MessageType.image)).called(1);
  });

  test('propagates repository errors', () async {
    when(() => repository.uploadPfp(file, MessageType.image)).thenThrow(Exception('boom'));

    expect(() => useCase(file, MessageType.image), throwsException);
  });
}

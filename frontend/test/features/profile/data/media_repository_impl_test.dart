import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/profile/data/media_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  test('all upload methods delegate to the datasource', () async {
    final ds = MockMediaRemoteDatasource();
    final repo = MediaRepositoryImpl(ds);
    final file = File('/tmp/x.png');

    when(() => ds.uploadChatMedia(file, MessageType.image))
        .thenAnswer((_) async => {'a': 1});
    expect(await repo.uploadChatMedia(file, MessageType.image), {'a': 1});

    when(() => ds.uploadUserMedia(file, MessageType.image))
        .thenAnswer((_) async => {'b': 2});
    expect(await repo.uploadUserMedia(file, MessageType.image), {'b': 2});

    when(() => ds.uploadPfp(file, MessageType.image))
        .thenAnswer((_) async => {'c': 3});
    expect(await repo.uploadPfp(file, MessageType.image), {'c': 3});

    when(() => ds.uploadPfpFromUrl('http://x'))
        .thenAnswer((_) async => {'d': 4});
    expect(await repo.uploadPfpFromUrl('http://x'), {'d': 4});
  });
}

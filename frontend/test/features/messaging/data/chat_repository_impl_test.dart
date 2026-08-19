import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/data/chat_repository_impl.dart';
import 'package:linkup/features/messaging/data/isar_classes/unsent_messages_table.dart';
import 'package:linkup/features/messaging/data/models/media_message_data_model.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/mocks.dart';

void main() {
  late MockChatRemoteDatasource chatDs;
  late MockMediaRemoteDatasource mediaDs;
  late MockMessageLocalDatasource localDs;
  late ChatRepositoryImpl repo;

  Message model({String id = 'm1'}) => Message(
        id: id,
        message: 'hi',
        to: 2,
        from_: 1,
        chatRoomId: 10,
        timestamp: DateTime(2026, 1, 1),
        media: MediaMessageData(
          fileKey: 'k',
          mediaType: MessageType.image,
          blurhashText: 'b',
          metadata: const {'w': 1},
        ),
      );

  setUpAll(() {
    registerFallbackValue(model());
  });

  setUp(() {
    chatDs = MockChatRemoteDatasource();
    mediaDs = MockMediaRemoteDatasource();
    localDs = MockMessageLocalDatasource();
    repo = ChatRepositoryImpl(
      chatDatasource: chatDs,
      mediaDatasource: mediaDs,
      localDatasource: localDs,
    );
  });

  test('startChat delegates', () async {
    when(() => chatDs.startChat(2))
        .thenAnswer((_) async => {'chat_room_id': 10});
    expect(await repo.startChat(2), {'chat_room_id': 10});
  });

  test('fetchMessages maps models (incl. media) to entities', () async {
    when(() => chatDs.fetchMessages(10)).thenAnswer((_) async => [model()]);
    final entities = await repo.fetchMessages(10);
    expect(entities.single.id, 'm1');
    expect(entities.single.media!.fileKey, 'k');
  });

  test('fetchPaginatedMessages maps and forwards the cursor', () async {
    final ts = DateTime(2026, 1, 1);
    when(() => chatDs.fetchPaginatedMessages(
          chatRoomId: 10,
          lastMessageId: 'm1',
          lastMessageTimeStamp: ts,
        )).thenAnswer((_) async => [model(id: 'm0')]);
    final entities = await repo.fetchPaginatedMessages(
        chatRoomId: 10, lastMessageId: 'm1', lastMessageTimeStamp: ts);
    expect(entities.single.id, 'm0');
  });

  test('cache operations convert entities to models', () async {
    when(() => localDs.getMessages(10)).thenAnswer((_) async => [model()]);
    expect((await repo.getCachedMessages(10)).single.id, 'm1');

    when(() => localDs.cacheMessage(any(), 20)).thenAnswer((_) async {});
    await repo.cacheMessage(makeMessage(media: makeMedia()), 20);
    final cached = verify(() => localDs.cacheMessage(captureAny(), 20))
        .captured
        .single as Message;
    expect(cached.media!.fileKey, 'file-key');

    when(() => localDs.saveUnsent(any())).thenAnswer((_) async {});
    await repo.saveUnsentMessage(makeMessage(isSent: false));
    verify(() => localDs.saveUnsent(any())).called(1);
  });

  test('unsent message operations delegate', () async {
    when(() => localDs.getAllUnsent()).thenAnswer(
        (_) async => [UnsentMessagesTable.fromMessage(model(id: 'u1'))]);
    expect((await repo.getUnsentMessages()).single.id, 'u1');

    when(() => localDs.deleteUnsent(1)).thenAnswer((_) async {});
    await repo.deleteUnsentMessage(1);
    verify(() => localDs.deleteUnsent(1)).called(1);

    when(() => localDs.deleteUnsentByMessageId('u1'))
        .thenAnswer((_) async {});
    await repo.deleteUnsentMessageByMsgId('u1');
    verify(() => localDs.deleteUnsentByMessageId('u1')).called(1);
  });

  test('uploadChatMedia delegates to the media datasource', () async {
    final file = File('/tmp/x.png');
    when(() => mediaDs.uploadChatMedia(file, MessageType.image))
        .thenAnswer((_) async => {'file_key': 'k'});
    expect(await repo.uploadChatMedia(file, MessageType.image),
        {'file_key': 'k'});
  });
}

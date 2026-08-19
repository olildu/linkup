@Tags(['isar'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:linkup/features/messaging/data/isar_classes/message_table.dart';
import 'package:linkup/features/messaging/data/isar_classes/unsent_messages_table.dart';
import 'package:linkup/features/messaging/data/message_local_datasource.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';

void main() {
  late Directory dir;
  late Isar isar;
  late MessageLocalDatasource ds;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_msg_test');
    isar = await Isar.open(
      [MessageTableSchema, UnsentMessagesTableSchema],
      directory: dir.path,
    );
    ds = MessageLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Message message({String id = 'm1', int room = 10, DateTime? ts}) => Message(
        id: id,
        message: 'text-$id',
        to: 2,
        from_: 1,
        chatRoomId: room,
        timestamp: ts ?? DateTime(2026, 1, 1),
      );

  test('cacheMessage stores and getMessages filters by chat room', () async {
    await ds.cacheMessage(message(id: 'a', room: 10), 20);
    await ds.cacheMessage(message(id: 'b', room: 11), 20);

    final room10 = await ds.getMessages(10);
    expect(room10.single.id, 'a');
  });

  test('cacheMessage evicts the oldest message once maxCount is reached',
      () async {
    await ds.cacheMessage(message(id: 'old', ts: DateTime(2026, 1, 1)), 2);
    await ds.cacheMessage(message(id: 'mid', ts: DateTime(2026, 1, 2)), 2);
    await ds.cacheMessage(message(id: 'new', ts: DateTime(2026, 1, 3)), 2);

    final ids = (await ds.getMessages(10)).map((m) => m.id).toSet();
    expect(ids, {'mid', 'new'});
  });

  test('replaceAll swaps the cached messages for a room', () async {
    await ds.cacheMessage(message(id: 'a'), 20);
    await ds.replaceAll(10, [message(id: 'x'), message(id: 'y')]);
    final ids = (await ds.getMessages(10)).map((m) => m.id).toSet();
    expect(ids, {'x', 'y'});
  });

  test('unsent message lifecycle: save, list, delete by id and message id',
      () async {
    await ds.saveUnsent(message(id: 'u1'));
    await ds.saveUnsent(message(id: 'u2'));

    var unsent = await ds.getAllUnsent();
    expect(unsent.map((r) => r.messageID).toSet(), {'u1', 'u2'});

    await ds.deleteUnsent(unsent.first.id);
    unsent = await ds.getAllUnsent();
    expect(unsent, hasLength(1));

    await ds.deleteUnsentByMessageId(unsent.single.messageID);
    expect(await ds.getAllUnsent(), isEmpty);
  });

  test('putMessage inserts and markSeen flips the flag', () async {
    await ds.putMessage(message(id: 'p1'));
    await ds.markSeen('p1');
    expect((await ds.getMessages(10)).single.isSeen, isTrue);

    // markSeen for an unknown id is a no-op.
    await ds.markSeen('nope');
  });
}

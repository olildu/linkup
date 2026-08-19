@Tags(['isar'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:linkup/features/connections/data/chat_local_datasource.dart';
import 'package:linkup/features/connections/data/chats_connection_model.dart';
import 'package:linkup/features/connections/data/isar_classes/chats_table.dart';

void main() {
  late Directory dir;
  late Isar isar;
  late ChatLocalDatasource ds;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('isar_chat_test');
    isar = await Isar.open([ChatsTableSchema], directory: dir.path);
    ds = ChatLocalDatasource(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  test('replaceAll clears and rewrites; getAll maps back to models', () async {
    await ds.replaceAll([
      ChatsConnectionModel(
        id: 3,
        username: 'bob',
        profilePictureMetaData: const {'url': 'b.jpg'},
        chatRoomId: 10,
        unseenCounter: 2,
        message: 'yo',
      ),
    ]);

    var all = await ds.getAll();
    expect(all.single.username, 'bob');
    expect(all.single.profilePictureMetaData, {'url': 'b.jpg'});

    await ds.replaceAll([
      ChatsConnectionModel(
        id: 4,
        username: 'carol',
        profilePictureMetaData: const {},
        chatRoomId: 11,
        unseenCounter: 0,
      ),
    ]);
    all = await ds.getAll();
    expect(all.single.username, 'carol');
  });
}

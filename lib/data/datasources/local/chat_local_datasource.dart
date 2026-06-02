import 'package:isar/isar.dart';
import 'package:linkup/data/isar_classes/chats_table.dart';
import 'package:linkup/data/models/chats_connection_model.dart';

class ChatLocalDatasource {
  final Isar _isar;

  ChatLocalDatasource(this._isar);

  Future<List<ChatsConnectionModel>> getAll() async {
    final rows = await _isar.chatsTables.where().findAll();
    return rows.map((r) => r.toChatsConnectionModel()).toList();
  }

  Future<void> replaceAll(List<ChatsConnectionModel> chats) async {
    await _isar.writeTxn(() async {
      await _isar.chatsTables.clear();
      for (final chat in chats) {
        await _isar.chatsTables.put(ChatsTable.fromChat(chat));
      }
    });
  }
}

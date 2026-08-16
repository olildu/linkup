import 'package:isar/isar.dart';
import 'package:linkup/data/isar_classes/message_table.dart';
import 'package:linkup/data/isar_classes/unsent_messages_table.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';

class MessageLocalDatasource {
  final Isar _isar;

  MessageLocalDatasource(this._isar);

  Future<List<Message>> getMessages(int chatRoomId) async {
    final rows = await _isar.messageTables
        .filter()
        .chatRoomIdEqualTo(chatRoomId)
        .findAll();
    return rows.map((r) => r.toMessage()).toList();
  }

  Future<void> cacheMessage(Message message, int maxCount) async {
    await _isar.writeTxn(() async {
      final count = await _isar.messageTables
          .filter()
          .chatRoomIdEqualTo(message.chatRoomId)
          .count();

      if (count >= maxCount) {
        final oldest = await _isar.messageTables
            .filter()
            .chatRoomIdEqualTo(message.chatRoomId)
            .sortByTimestamp()
            .findFirst();
        if (oldest != null) await _isar.messageTables.delete(oldest.id);
      }

      await _isar.messageTables.put(MessageTable.fromMessage(message));
    });
  }

  Future<void> replaceAll(int chatRoomId, List<Message> messages) async {
    await _isar.writeTxn(() async {
      await _isar.messageTables
          .filter()
          .chatRoomIdEqualTo(chatRoomId)
          .deleteAll();
      for (final m in messages) {
        await _isar.messageTables.put(MessageTable.fromMessage(m));
      }
    });
  }

  Future<void> saveUnsent(Message message) async {
    await _isar.writeTxn(() async {
      await _isar.unsentMessagesTables.put(
        UnsentMessagesTable.fromMessage(message),
      );
    });
  }

  Future<List<UnsentMessagesTable>> getAllUnsent() =>
      _isar.unsentMessagesTables.where().findAll();

  Future<void> deleteUnsent(int isarId) async {
    await _isar.writeTxn(() async {
      await _isar.unsentMessagesTables.delete(isarId);
    });
  }

  Future<void> deleteUnsentByMessageId(String messageId) async {
    await _isar.writeTxn(() async {
      await _isar.unsentMessagesTables
          .filter()
          .messageIDEqualTo(messageId)
          .deleteAll();
    });
  }

  Future<void> putMessage(Message message) async {
    await _isar.writeTxn(() async {
      await _isar.messageTables.put(MessageTable.fromMessage(message));
    });
  }

  Future<void> markSeen(String messageId) async {
    await _isar.writeTxn(() async {
      final row = await _isar.messageTables
          .filter()
          .messageIDEqualTo(messageId)
          .findFirst();
      if (row != null) {
        row.isSeen = true;
        await _isar.messageTables.put(row);
      }
    });
  }
}

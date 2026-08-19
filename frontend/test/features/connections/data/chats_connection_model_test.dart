import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/connections/data/chats_connection_model.dart';

void main() {
  group('ChatsConnectionModel', () {
    test('fromJson maps media type and defaults is_deleted', () {
      final model = ChatsConnectionModel.fromJson({
        'id': 3,
        'username': 'bob',
        'profile_picture': {'url': 'b.jpg'},
        'chat_room_id': 10,
        'unseen_counter': 2,
        'last_message': 'yo',
        'last_message_media_type': 'image',
      });
      expect(model.id, 3);
      expect(model.message, 'yo');
      expect(model.messageType, MessageType.image);
      expect(model.isDeleted, isFalse);
    });

    test('fromJson respects is_deleted and unknown media type falls back to text', () {
      final model = ChatsConnectionModel.fromJson({
        'id': 3,
        'username': 'bob',
        'profile_picture': {'url': 'b.jpg'},
        'chat_room_id': 10,
        'unseen_counter': 0,
        'is_deleted': true,
      });
      expect(model.isDeleted, isTrue);
      expect(model.messageType, MessageType.text);
    });

    test('copyWith overrides only the provided fields', () {
      final original = ChatsConnectionModel.fromJson({
        'id': 3,
        'username': 'bob',
        'profile_picture': {'url': 'b.jpg'},
        'chat_room_id': 10,
        'unseen_counter': 2,
      });
      final copy = original.copyWith(unseenCounter: 0, message: 'new');
      expect(copy.unseenCounter, 0);
      expect(copy.message, 'new');
      expect(copy.id, 3);
      expect(copy.username, 'bob');

      final unchanged = original.copyWith();
      expect(unchanged.chatRoomId, 10);
    });
  });
}

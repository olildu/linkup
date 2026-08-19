import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/data/models/media_message_data_model.dart';
import 'package:linkup/features/messaging/data/models/message_model.dart';

void main() {
  group('Message.fromJson', () {
    test('parses a full payload', () {
      final message = Message.fromJson({
        'message_id': 'm1',
        'message': 'hello',
        'to': 2,
        'from_': 1,
        'timestamp': '2026-01-01T12:00:00.000',
        'chat_room_id': 10,
        'is_seen': true,
        'is_sent': false,
        'reply_id': 'r1',
        'media': {
          'file_key': 'k',
          'media_type': 'image',
          'blurhash_text': 'h',
          'metadata': <String, dynamic>{},
        },
      });
      expect(message.id, 'm1');
      expect(message.message, 'hello');
      expect(message.to, 2);
      expect(message.from_, 1);
      expect(message.timestamp, DateTime(2026, 1, 1, 12));
      expect(message.chatRoomId, 10);
      expect(message.isSeen, isTrue);
      expect(message.isSent, isFalse);
      expect(message.replyID, 'r1');
      expect(message.media!.fileKey, 'k');
    });

    test('generates an id and defaults when fields are missing', () {
      final before = DateTime.now();
      final message = Message.fromJson({
        'message': 'hi',
        'to': 2,
        'from_': 1,
        'chat_room_id': 10,
      });
      expect(message.id, isNotEmpty);
      expect(message.timestamp.isBefore(before), isFalse);
      expect(message.isSeen, isFalse);
      expect(message.isSent, isTrue);
      expect(message.media, isNull);
      expect(message.replyID, isNull);
    });
  });

  group('Message.toJson', () {
    test('includes media and reply_id only when present', () {
      final ts = DateTime(2026, 1, 1);
      final bare = Message(
          id: 'm1',
          message: 'x',
          to: 2,
          from_: 1,
          chatRoomId: 10,
          timestamp: ts);
      expect(bare.toJson().containsKey('media'), isFalse);
      expect(bare.toJson().containsKey('reply_id'), isFalse);
      expect(bare.toJson()['type'], 'chats');
      expect(bare.toJson()['chats_type'], 'message');

      final full = Message(
        id: 'm2',
        message: 'y',
        to: 2,
        from_: 1,
        chatRoomId: 10,
        timestamp: ts,
        replyID: 'r1',
        media: MediaMessageData(
            fileKey: 'k',
            mediaType: MessageType.image,
            blurhashText: '',
            metadata: const {}),
      );
      expect(full.toJson()['reply_id'], 'r1');
      expect(full.toJson()['media'], isA<Map<String, dynamic>>());
    });
  });

  test('copyWith overrides only the provided fields', () {
    final ts = DateTime(2026, 1, 1);
    final original = Message(
        id: 'm1', message: 'x', to: 2, from_: 1, chatRoomId: 10, timestamp: ts);
    final copy = original.copyWith(isSeen: true, message: 'edited');
    expect(copy.isSeen, isTrue);
    expect(copy.message, 'edited');
    expect(copy.id, 'm1');
    expect(copy.to, 2);
    expect(copy.timestamp, ts);

    final identicalCopy = original.copyWith();
    expect(identicalCopy.id, original.id);
    expect(identicalCopy.isSeen, original.isSeen);
  });
}

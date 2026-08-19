import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/data/models/media_message_data_model.dart';

void main() {
  group('MediaMessageData', () {
    test('fromJson parses all fields', () {
      final model = MediaMessageData.fromJson({
        'file_key': 'k1',
        'media_type': 'voice',
        'blurhash_text': 'hash',
        'metadata': {'duration': 3},
      });
      expect(model.fileKey, 'k1');
      expect(model.mediaType, MessageType.voice);
      expect(model.blurhashText, 'hash');
      expect(model.metadata, {'duration': 3});
    });

    test('fromJson defaults unknown media_type to image and missing blurhash to empty', () {
      final model = MediaMessageData.fromJson({
        'file_key': 'k1',
        'media_type': 'unknown',
        'metadata': <String, dynamic>{},
      });
      expect(model.mediaType, MessageType.image);
      expect(model.blurhashText, '');
    });

    test('toJson emits all fields', () {
      final model = MediaMessageData(
        fileKey: 'k1',
        mediaType: MessageType.image,
        blurhashText: 'hash',
        metadata: const {'w': 1},
      );
      expect(model.toJson(), {
        'file_key': 'k1',
        'mediaType': 'image',
        'blurhashText': 'hash',
        'metadata': {'w': 1},
      });
    });
  });
}

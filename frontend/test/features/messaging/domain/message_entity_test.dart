import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('copyWith overrides only the provided fields', () {
    final original = makeMessage();
    final copy = original.copyWith(isSeen: true, message: 'edited');
    expect(copy.isSeen, isTrue);
    expect(copy.message, 'edited');
    expect(copy.id, original.id);
    expect(copy.to, original.to);
    expect(copy.from_, original.from_);
    expect(copy.chatRoomId, original.chatRoomId);
    expect(copy.timestamp, original.timestamp);

    final withMedia = original.copyWith(media: makeMedia());
    expect(withMedia.media!.fileKey, 'file-key');

    final unchanged = original.copyWith();
    expect(unchanged.message, original.message);
    expect(unchanged.isSent, original.isSent);
  });
}

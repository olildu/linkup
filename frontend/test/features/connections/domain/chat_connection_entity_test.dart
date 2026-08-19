import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';

import '../../../helpers/fixtures.dart';

void main() {
  test('copyWith overrides only the provided fields', () {
    final original = makeChatConnection();
    final copy = original.copyWith(unseenCounter: 0, message: 'newest');
    expect(copy.unseenCounter, 0);
    expect(copy.message, 'newest');
    expect(copy.id, original.id);
    expect(copy.username, original.username);
    expect(copy.chatRoomId, original.chatRoomId);
    expect(copy.messageType, MessageType.text);

    final unchanged = original.copyWith();
    expect(unchanged.unseenCounter, original.unseenCounter);
    expect(unchanged.isDeleted, original.isDeleted);
  });
}

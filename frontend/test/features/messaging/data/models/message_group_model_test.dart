import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/data/models/message_group_model.dart';

void main() {
  test('MessageGroupModel stores fields and defaults emoji flags to false', () {
    final model = MessageGroupModel(
      isFirstInGroup: true,
      isLastInGroup: false,
      isOnlyMessageInGroup: false,
      groupSize: 3,
      positionInGroup: 0,
    );
    expect(model.isFirstInGroup, isTrue);
    expect(model.isLastInGroup, isFalse);
    expect(model.isOnlyMessageInGroup, isFalse);
    expect(model.groupSize, 3);
    expect(model.positionInGroup, 0);
    expect(model.prevMessageEmoji, isFalse);
    expect(model.nextMessageEmoji, isFalse);
  });
}

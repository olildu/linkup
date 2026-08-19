import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/data/models/live_chat_data_model.dart';

void main() {
  test('LiveChatDataModel stores fields and defaults changeOrder to false', () {
    final model = LiveChatDataModel(
      unseenCounterIncBy: 1,
      from_: 2,
      chatRoomId: 10,
      messageType: MessageType.text,
      message: 'hey',
    );
    expect(model.from_, 2);
    expect(model.chatRoomId, 10);
    expect(model.unseenCounterIncBy, 1);
    expect(model.messageType, MessageType.text);
    expect(model.message, 'hey');
    expect(model.changeOrder, isFalse);
  });
}

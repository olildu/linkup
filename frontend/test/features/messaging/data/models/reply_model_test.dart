import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/messaging/data/models/reply_model.dart';

void main() {
  test('ReplyModel stores its fields', () {
    final reply = ReplyModel(messageID: 'm1', message: 'hi', userName: 'bob');
    expect(reply.messageID, 'm1');
    expect(reply.message, 'hi');
    expect(reply.userName, 'bob');
  });
}

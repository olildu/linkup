import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/enums/message_type_enum.dart';

void main() {
  test('messageTypeFromString maps known values and defaults to text', () {
    expect(messageTypeFromString('voice'), MessageType.voice);
    expect(messageTypeFromString('image'), MessageType.image);
    expect(messageTypeFromString('text'), MessageType.text);
    expect(messageTypeFromString('bogus'), MessageType.text);
    expect(messageTypeFromString(null), MessageType.text);
  });
}

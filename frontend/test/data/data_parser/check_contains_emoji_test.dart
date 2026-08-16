import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/data/data_parser/common/check_contains_emoji.dart';

void main() {
  group('containsOnlyEmojis', () {
    test('returns true for single emoji', () {
      expect(containsOnlyEmojis('😀'), isTrue);
    });

    test('returns true for multiple emojis', () {
      expect(containsOnlyEmojis('😀😎🔥'), isTrue);
    });

    test('returns false for text', () {
      expect(containsOnlyEmojis('Hello'), isFalse);
    });

    test('returns false for mixed text and emoji', () {
      expect(containsOnlyEmojis('Hello 😀'), isFalse);
    });

    test('returns false for empty string', () {
      expect(containsOnlyEmojis(''), isFalse);
    });
  });
}
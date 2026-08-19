import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/utils/validation_utils.dart';

void main() {
  group('validateEmail', () {
    test('accepts standard addresses', () {
      expect(ValidationUtils.validateEmail('a@b.com'), isTrue);
      expect(ValidationUtils.validateEmail('first.last@uni.edu.in'), isTrue);
    });
    test('rejects malformed addresses', () {
      expect(ValidationUtils.validateEmail('nope'), isFalse);
      expect(ValidationUtils.validateEmail('a@b'), isFalse);
      expect(ValidationUtils.validateEmail('@b.com'), isFalse);
    });
  });

  group('validateOTP', () {
    test('requires exactly six characters', () {
      expect(ValidationUtils.validateOTP('123456'), isTrue);
      expect(ValidationUtils.validateOTP('12345'), isFalse);
      expect(ValidationUtils.validateOTP('1234567'), isFalse);
    });
  });

  group('validatePassword', () {
    test('rejects short passwords', () {
      expect(ValidationUtils.validatePassword('Ab1!'), isFalse);
    });
    test('login mode only checks length', () {
      expect(ValidationUtils.validatePassword('longenough', isLogin: true), isTrue);
    });
    test('signup mode requires upper, lower, digit and special', () {
      expect(ValidationUtils.validatePassword('Abcdef1!'), isTrue);
      expect(ValidationUtils.validatePassword('abcdef1!'), isFalse);
      expect(ValidationUtils.validatePassword('ABCDEF1!'), isFalse);
      expect(ValidationUtils.validatePassword('Abcdefg!'), isFalse);
      expect(ValidationUtils.validatePassword('Abcdefg1'), isFalse);
    });
  });
}

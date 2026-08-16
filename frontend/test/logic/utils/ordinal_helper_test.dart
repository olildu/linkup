import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/logic/utils/ordinal_helper.dart';

void main() {
  group('getOrdinalSuffix', () {
    test('returns st for 1', () {
      expect(getOrdinalSuffix(1), '1st');
    });

    test('returns nd for 2', () {
      expect(getOrdinalSuffix(2), '2nd');
    });

    test('returns rd for 3', () {
      expect(getOrdinalSuffix(3), '3rd');
    });

    test('returns th for 4', () {
      expect(getOrdinalSuffix(4), '4th');
    });

    test('returns th for 11, 12, 13 (exceptions)', () {
      expect(getOrdinalSuffix(11), '11th');
      expect(getOrdinalSuffix(12), '12th');
      expect(getOrdinalSuffix(13), '13th');
    });

    test('returns st for 21, nd for 22', () {
      expect(getOrdinalSuffix(21), '21st');
      expect(getOrdinalSuffix(22), '22nd');
    });
    
    test('handles negative or zero gracefully', () {
      expect(getOrdinalSuffix(0), '0');
      expect(getOrdinalSuffix(-5), '-5');
    });
  });
}
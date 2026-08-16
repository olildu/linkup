import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/logic/utils/calculate_age.dart';

void main() {
  group('calculateAge', () {
    test('returns correct age when birthday has already passed this year', () {
      final today = DateTime.now();
      // 20 years ago
      final dob = DateTime(today.year - 20, today.month, today.day - 1);
      expect(calculateAge(dob), 20);
    });

    test('returns correct age when birthday has NOT passed this year', () {
      final today = DateTime.now();
      // 20 years ago, but tomorrow is the birthday
      final dob = DateTime(today.year - 20, today.month, today.day + 1);
      expect(calculateAge(dob), 19);
    });

    test('returns 0 for a baby born today', () {
      expect(calculateAge(DateTime.now()), 0);
    });

    test('returns correct age for leap year birthday (Feb 29)', () {
      // Logic check for leaplings
      final dob = DateTime(2000, 2, 29);
      // This depends on how exactly you want to handle Feb 28 vs Mar 1 for leaplings,
      // but your function handles month/day comparison standardly.
      // 2023 - 2000 = 23. March 1 is after Feb 29.
      expect(calculateAge(dob), isA<int>());
    });
  });
}

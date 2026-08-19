import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/onboarding/data/models/signup_options_model.dart';

void main() {
  group('SignupProgramOption', () {
    test('fromJson/toJson round-trip', () {
      final option = SignupProgramOption.fromJson(
          {'id': 'btech', 'label': 'BTech', 'years': 4});
      expect(option.id, 'btech');
      expect(option.label, 'BTech');
      expect(option.years, 4);
      expect(option.toJson(), {'id': 'btech', 'label': 'BTech', 'years': 4});
    });
  });

  group('SignupOptionsConfig', () {
    test('fromJson parses programs and defaults version/empty list', () {
      final config = SignupOptionsConfig.fromJson({
        'version': 2,
        'programs': [
          {'id': 'bsc', 'label': 'BSc', 'years': 3},
        ],
      });
      expect(config.version, 2);
      expect(config.programs.single.id, 'bsc');

      final defaulted = SignupOptionsConfig.fromJson({});
      expect(defaulted.version, 1);
      expect(defaulted.programs, isEmpty);
    });

    test('fallback provides btech and bsc', () {
      final fallback = SignupOptionsConfig.fallback();
      expect(fallback.programLabels, ['BTech', 'BSc']);
    });

    test('programForValue matches by id or label, null for unknown', () {
      final config = SignupOptionsConfig.fallback();
      expect(config.programForValue('btech')!.label, 'BTech');
      expect(config.programForValue('BSc')!.id, 'bsc');
      expect(config.programForValue('mba'), isNull);
      expect(config.programForValue(null), isNull);
    });

    test('defaultProgram falls back when programs is empty', () {
      const empty = SignupOptionsConfig(version: 1, programs: []);
      expect(empty.defaultProgram.id, 'btech');
      expect(SignupOptionsConfig.fallback().defaultProgram.id, 'btech');
    });

    test('yearLabelsForProgram generates 1..years and uses default when null', () {
      final config = SignupOptionsConfig.fallback();
      expect(config.yearLabelsForProgram(config.programs.last), ['1', '2', '3']);
      expect(config.yearLabelsForProgram(null), ['1', '2', '3', '4']);
    });

    test('toJson round-trips', () {
      final config = SignupOptionsConfig.fallback();
      expect(config.toJson()['version'], 1);
      expect((config.toJson()['programs'] as List).length, 2);
    });
  });
}

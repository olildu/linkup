import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/city_lookup/data/university_info_model.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:linkup/features/profile/data/models/user_model.dart';

void main() {
  group('UniversityInfoModel', () {
    test('fromJson parses fields and defaults when missing', () {
      final model = UniversityInfoModel.fromJson({
        'universityMajor': 'CS',
        'universityYear': 3,
      });
      expect(model.universityMajor, 'CS');
      expect(model.universityYear, 3);

      final defaulted = UniversityInfoModel.fromJson({});
      expect(defaulted.universityMajor, '');
      expect(defaulted.universityYear, 0);
    });

    test('builds from MatchCandidateModel and UserModel', () {
      final candidate = MatchCandidateModel(
        id: 1,
        username: 'a',
        gender: 'Male',
        universityId: 1,
        profilePictureMetaData: const {},
        dob: DateTime(2000),
        universityMajor: 'EE',
        universityYear: 2,
        photos: const [],
        about: '',
        currentlyStaying: '',
        hometown: '',
      );
      expect(UniversityInfoModel.fromMatchCandidate(candidate).universityMajor, 'EE');

      final user = UserModel(
        id: 1,
        universityId: 1,
        universityMajor: 'ME',
        universityYear: 4,
      );
      final fromUser = UniversityInfoModel.fromUserModel(user);
      expect(fromUser.universityMajor, 'ME');
      expect(fromUser.universityYear, 4);
    });

    test('toJson and asIconMap expose the values', () {
      const model = UniversityInfoModel(universityMajor: 'CS', universityYear: 3);
      expect(model.toJson(), {'universityMajor': 'CS', 'universityYear': 3});

      final iconMap = model.asIconMap();
      expect(iconMap['universityMajor']!['value'], 'CS');
      expect(iconMap['universityMajor']!['icon'], Icons.school_rounded);
      expect(iconMap['universityYear']!['value'], 'Year 3');
    });
  });
}

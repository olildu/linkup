import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';
import 'package:linkup/features/profile/data/models/candidate_info_model.dart';
import 'package:linkup/features/profile/data/models/user_model.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const full = CandidateInfoModel(
    id: 7,
    height: 170,
    weight: 60,
    religion: 'None',
    smokingInfo: 'No',
    drinkingInfo: 'No',
    lookingFor: 'Serious',
    gender: 'Male',
    currentlyStaying: 'PG',
    hometown: 'City B',
  );

  test('fromJson parses all fields', () {
    final model = CandidateInfoModel.fromJson({
      'id': 7,
      'height': 170,
      'weight': 60,
      'religion': 'None',
      'smoking_info': 'No',
      'drinking_info': 'No',
      'looking_for': 'Serious',
      'gender': 'Male',
      'currently_staying': 'PG',
      'hometown': 'City B',
    });
    expect(model.id, 7);
    expect(model.height, 170);
    expect(model.gender, 'Male');
  });

  test('builds from MatchCandidateModel, UserModel and entities', () {
    final candidate = MatchCandidateModel(
      id: 1,
      username: 'a',
      gender: 'Female',
      universityId: 1,
      profilePictureMetaData: const {},
      dob: DateTime(2000),
      universityMajor: 'EE',
      universityYear: 2,
      photos: const [],
      about: '',
      currentlyStaying: 'Hostel',
      hometown: 'Home',
      height: 160,
    );
    final fromCandidate = CandidateInfoModel.fromMatchCandidate(candidate);
    expect(fromCandidate.id, 1);
    expect(fromCandidate.height, 160);
    expect(fromCandidate.gender, 'Female');

    final user = UserModel(
      id: 2,
      universityId: 1,
      gender: 'Male',
      height: 180,
      hometown: 'Town',
    );
    final fromUser = CandidateInfoModel.fromUserModel(user);
    expect(fromUser.id, isNull);
    expect(fromUser.height, 180);

    final fromEntity = CandidateInfoModel.fromUserEntity(makeUser());
    expect(fromEntity.height, 180);
    expect(fromEntity.gender, 'male');

    final fromCandidateEntity =
        CandidateInfoModel.fromMatchCandidateEntity(makeCandidate());
    expect(fromCandidateEntity.id, 7);
    expect(fromCandidateEntity.height, 170);
  });

  test('toJson emits snake_case keys', () {
    final json = full.toJson();
    expect(json['smoking_info'], 'No');
    expect(json['currently_staying'], 'PG');
    expect(json.containsKey('id'), isFalse);
  });

  group('asIconMap', () {
    test('includes gender and location sections by default', () {
      final map = full.asIconMap();
      expect(map['gender']!['icon'], Icons.man_rounded);
      expect(map['gender']!['value'], 'Male');
      expect(map['currently_staying']!['value'], 'PG');
      expect(map['hometown']!['value'], 'City B');
      expect(map['height']!['value'], '170 cm');
      expect(map['weight']!['value'], '60 kg');
      expect(map['looking_for']!['value'], 'Serious');
    });

    test('uses woman icon for non-male gender and hides optional sections', () {
      const female = CandidateInfoModel(gender: 'Female');
      final map =
          female.asIconMap(showGender: true, showLocationInfo: false);
      expect(map['gender']!['icon'], Icons.woman_rounded);
      expect(map.containsKey('currently_staying'), isFalse);

      final noGender = female.asIconMap(showGender: false);
      expect(noGender.containsKey('gender'), isFalse);
    });

    test('renders null height/weight as null values', () {
      const empty = CandidateInfoModel();
      final map = empty.asIconMap();
      expect(map['height']!['value'], isNull);
      expect(map['weight']!['value'], isNull);
    });
  });
}

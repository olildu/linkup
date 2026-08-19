import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/data/match_candidate_model.dart';

Map<String, dynamic> fullJson() => {
      'id': 7,
      'username': 'alice',
      'gender': 'Female',
      'university_id': 1,
      'profile_picture': {'url': 'p.jpg'},
      'dob': '2000-05-20T00:00:00.000',
      'university_major': 'CS',
      'university_year': 3,
      'photos': [
        {'url': 'a.jpg'}
      ],
      'about': 'hi',
      'currently_staying': 'PG',
      'hometown': 'City B',
      'height': 170,
      'weight': 60,
      'religion': 'None',
      'smoking_info': 'No',
      'drinking_info': 'No',
      'looking_for': 'Serious',
    };

void main() {
  group('MatchCandidateModel', () {
    test('fromJson parses a full payload', () {
      final model = MatchCandidateModel.fromJson(fullJson());
      expect(model.id, 7);
      expect(model.username, 'alice');
      expect(model.gender, 'Female');
      expect(model.dob, DateTime(2000, 5, 20));
      expect(model.photos, [
        {'url': 'a.jpg'}
      ]);
      expect(model.height, 170);
      expect(model.lookingFor, 'Serious');
    });

    test('fromJson defaults missing photos to an empty list', () {
      final json = fullJson()..remove('photos');
      expect(MatchCandidateModel.fromJson(json).photos, isEmpty);
    });

    test('toJson drops null optional fields', () {
      final json = fullJson()
        ..remove('height')
        ..remove('weight')
        ..remove('religion')
        ..remove('smoking_info')
        ..remove('drinking_info')
        ..remove('looking_for');
      final out = MatchCandidateModel.fromJson(json).toJson();
      expect(out.containsKey('height'), isFalse);
      expect(out.containsKey('religion'), isFalse);
      expect(out['username'], 'alice');
      expect(out['dob'], '2000-05-20T00:00:00.000');
    });
  });
}

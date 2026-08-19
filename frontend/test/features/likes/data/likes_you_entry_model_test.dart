import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/data/likes_you_entry_model.dart';

void main() {
  group('LikesYouEntryModel.fromJson', () {
    test('parses a revealed entry with a profile', () {
      final model = LikesYouEntryModel.fromJson({
        'id': 5,
        'revealed': true,
        'profile': {
          'id': 7,
          'username': 'alice',
          'gender': 'Female',
          'university_id': 1,
          'profile_picture': {'url': 'p.jpg'},
          'dob': '2000-05-20T00:00:00.000',
          'university_major': 'CS',
          'university_year': 3,
          'photos': [],
          'about': 'hi',
          'currently_staying': 'PG',
          'hometown': 'City B',
        },
      });
      expect(model.id, 5);
      expect(model.revealed, isTrue);
      expect(model.profile!.username, 'alice');
      expect(model.firstPhoto, isNull);
    });

    test('parses a hidden entry with only a first photo', () {
      final model = LikesYouEntryModel.fromJson({
        'id': 6,
        'revealed': false,
        'first_photo': {'url': 'blur.jpg'},
      });
      expect(model.revealed, isFalse);
      expect(model.profile, isNull);
      expect(model.firstPhoto, {'url': 'blur.jpg'});
    });
  });
}

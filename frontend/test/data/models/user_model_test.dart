import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    final mockUserMap = {
      'id': 123,
      'username': 'Test User',
      'gender': 'Male',
      'university_id': 456,
      'profile_picture': {'url': 'http://example.com/pic.jpg', 'blurhash': 'LEHV6n'},
      'dob': '2000-01-01T00:00:00.000',
      'university_major': 'CS',
      'university_year': 3,
      'photos': [],
      'about': 'Hello world',
      'currently_staying': 'Hostel',
      'hometown': 'City',
      'height': 180,
      'weight': 75,
      'religion': 'Other',
      'smoking_info': 'No',
      'drinking_info': 'No',
      'looking_for': 'Friends'
    };

    test('fromJson creates a valid UserModel', () {
      final user = UserModel.fromJson(mockUserMap);

      expect(user.id, 123);
      expect(user.username, 'Test User');
      expect(user.dob, DateTime(2000, 1, 1));
      expect(user.universityMajor, 'CS');
    });

    test('toJson creates a valid Map', () {
      final user = UserModel.fromJson(mockUserMap);
      final json = user.toJson();

      expect(json['id'], 123);
      expect(json['username'], 'Test User');
      expect(json['university_id'], 456);
      // Ensure DOB was converted back to string ISO
      expect(json['dob'], contains('2000-01-01')); 
    });
  });
}
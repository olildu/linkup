import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/entities/update_metadata_model.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromJson parses fields and null dob', () {
    final model = UpdateMetadataModel.fromJson({
      'university_major': 'CS',
      'university_year': 3,
      'username': 'u',
      'dob': '2000-05-20T00:00:00.000',
      'gender': 'Male',
      'interested_gender': 'Female',
      'profile_picture': {'url': 'p.jpg'},
      'photos': ['a.jpg'],
      'about': 'hi',
      'currently_staying': 'PG',
      'hometown': 'Home',
      'height': 170,
      'weight': 60,
      'religion': 'None',
      'smoking_info': 'No',
      'drinking_info': 'No',
      'looking_for': 'Serious',
    });
    expect(model.username, 'u');
    expect(model.dob, DateTime(2000, 5, 20));
    expect(model.height, 170);

    final noDob = UpdateMetadataModel.fromJson({'username': 'v'});
    expect(noDob.dob, isNull);
  });

  test('toJson emits snake_case keys and ISO dob', () {
    final json = UpdateMetadataModel(
      username: 'u',
      dob: DateTime(2000, 5, 20),
      height: 170,
    ).toJson();
    expect(json['username'], 'u');
    expect(json['dob'], '2000-05-20T00:00:00.000');
    expect(json['height'], 170);
    expect(json['about'], isNull);
  });

  test('fromUserEntity copies every mapped field', () {
    final model = UpdateMetadataModel.fromUserEntity(makeUser());
    expect(model.username, 'me');
    expect(model.universityMajor, 'EE');
    expect(model.height, 180);
    expect(model.lookingFor, 'relationship');
  });
}

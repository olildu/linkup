import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/discovery/data/matches_connection_model.dart';

void main() {
  test('fromJson parses fields', () {
    final model = MatchesConnectionModel.fromJson({
      'id': 4,
      'username': 'carol',
      'profile_picture': {'url': 'c.jpg'},
    });
    expect(model.id, 4);
    expect(model.username, 'carol');
    expect(model.profilePictureMetaData, {'url': 'c.jpg'});
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/likes/data/likes_you_response_model.dart';

void main() {
  test('fromJson parses entries and counts', () {
    final model = LikesYouResponseModel.fromJson({
      'entries': [
        {'id': 1, 'revealed': false},
        {'id': 2, 'revealed': false},
      ],
      'total_count': 9,
      'unseen_count': 2,
    });
    expect(model.entries.length, 2);
    expect(model.entries.first.id, 1);
    expect(model.totalCount, 9);
    expect(model.unseenCount, 2);
  });
}

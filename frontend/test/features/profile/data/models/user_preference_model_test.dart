import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/data/models/user_preference_model.dart';

void main() {
  test('fromJson/toJson round-trip preserves every field', () {
    final json = {
      'interested_gender': 'female',
      'height': 165,
      'weight': 55,
      'religion': 'None',
      'drinking_status': false,
      'smoking_status': true,
      'looking_for': 'Serious',
      'currently_staying': 'PG',
    };
    final model = UserPreferenceModel.fromJson(json);
    expect(model.interestedGender, 'female');
    expect(model.height, 165);
    expect(model.smokingStatus, isTrue);
    expect(model.toJson(), json);
  });

  test('handles all-null payloads', () {
    final model = UserPreferenceModel.fromJson({});
    expect(model.interestedGender, isNull);
    expect(model.toJson()['height'], isNull);
  });
}

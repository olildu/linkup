import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/features/profile/data/models/image_model.dart';

void main() {
  test('fromJson parses url and blurhash', () {
    final model = ImageModel.fromJson({'url': 'x.jpg', 'blurhash': 'h'});
    expect(model.url, 'x.jpg');
    expect(model.blurHash, 'h');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/utils/data_validator_provider.dart';

void main() {
  test('allowDisallow updates allowNext and notifies listeners', () {
    final provider = DataValidatorProvider();
    expect(provider.allowNext, isFalse);

    var notified = 0;
    provider.addListener(() => notified++);

    provider.allowDisallow(true);
    expect(provider.allowNext, isTrue);
    expect(notified, 1);

    provider.allowDisallow(false);
    expect(provider.allowNext, isFalse);
    expect(notified, 2);
  });
}

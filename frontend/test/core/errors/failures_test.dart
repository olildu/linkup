import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/errors/failures.dart';

void main() {
  test('each Failure subtype carries its message', () {
    const failures = <Failure>[
      NetworkFailure('net'),
      ServerFailure('srv'),
      AuthFailure('auth'),
      CacheFailure('cache'),
    ];
    expect(failures.map((f) => f.message), ['net', 'srv', 'auth', 'cache']);
    expect(failures.first, isA<NetworkFailure>());
  });
}

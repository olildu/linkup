import 'package:flutter_test/flutter_test.dart';
import 'package:linkup/core/errors/api_exception.dart';

void main() {
  test('ApiException stores fields and toString returns the friendly message', () {
    final e = ApiException(
      statusCode: 404,
      message: 'Not found, sorry!',
      rawDetail: 'resource 42 missing',
    );
    expect(e.statusCode, 404);
    expect(e.rawDetail, 'resource 42 missing');
    expect(e.toString(), 'Not found, sorry!');
  });

  test('SwipeLimitException toString returns its message', () {
    expect(SwipeLimitException('Out of swipes').toString(), 'Out of swipes');
  });

  test('AccountNotFoundException toString returns its message', () {
    expect(AccountNotFoundException('No account').toString(), 'No account');
  });
}

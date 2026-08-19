import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockFlutterSecureStorage storage;

  setUp(() {
    storage = MockFlutterSecureStorage();
    when(() => storage.read(key: 'access_token'))
        .thenAnswer((_) async => 'token-1');
  });

  CustomHttpClient buildClient(MockClient mock) =>
      CustomHttpClient(httpClient: mock, storage: storage);

  test('get attaches auth and content-type headers and returns 2xx responses',
      () async {
    late http.Request seen;
    final client = buildClient(MockClient((req) async {
      seen = req;
      return http.Response('{"ok":true}', 200);
    }));

    final res = await client.get(Uri.parse('https://x.test/a'));
    expect(res.statusCode, 200);
    expect(seen.headers['Authorization'], 'Bearer token-1');
    expect(seen.headers['Content-Type'], startsWith('application/json'));
  });

  test('post and delete forward their bodies', () async {
    final seen = <http.Request>[];
    final client = buildClient(MockClient((req) async {
      seen.add(req);
      return http.Response('{}', 200);
    }));

    await client.post(Uri.parse('https://x.test/a'), body: '{"a":1}');
    await client.delete(Uri.parse('https://x.test/a'), body: '{"b":2}');

    expect(seen[0].method, 'POST');
    expect(seen[0].body, '{"a":1}');
    expect(seen[1].method, 'DELETE');
    expect(seen[1].body, '{"b":2}');
  });

  test('throws ApiException with backend detail on non-2xx', () async {
    final client = buildClient(MockClient((_) async =>
        http.Response('{"detail":"Email already registered"}', 400)));

    try {
      await client.get(Uri.parse('https://x.test/a'));
      fail('should throw');
    } on ApiException catch (e) {
      expect(e.statusCode, 400);
      expect(e.rawDetail, 'Email already registered');
      expect(e.message, isNot(contains('Exception')));
    }
  });

  test('maps 429 to SwipeLimitException', () async {
    final client = buildClient(MockClient(
        (_) async => http.Response('{"detail":"limit reached"}', 429)));
    expect(() => client.get(Uri.parse('https://x.test/a')),
        throwsA(isA<SwipeLimitException>()));
  });

  test('handles non-json error bodies gracefully', () async {
    final client = buildClient(
        MockClient((_) async => http.Response('<html>bad</html>', 500)));
    expect(
      () => client.get(Uri.parse('https://x.test/a')),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 500)
          .having((e) => e.rawDetail, 'rawDetail', '')),
    );
  });

  test('maps SocketException to a friendly offline ApiException', () async {
    final client = buildClient(
        MockClient((_) async => throw const SocketException('no route')));
    expect(
      () => client.get(Uri.parse('https://x.test/a')),
      throwsA(isA<ApiException>()
          .having((e) => e.rawDetail, 'rawDetail', 'socket_exception')),
    );
  });

  test('maps HttpException and FormatException', () async {
    final httpClient = buildClient(
        MockClient((_) async => throw const HttpException('nope')));
    expect(
      () => httpClient.get(Uri.parse('https://x.test/a')),
      throwsA(isA<ApiException>()
          .having((e) => e.rawDetail, 'rawDetail', 'http_exception')),
    );

    final fmtClient = buildClient(
        MockClient((_) async => throw const FormatException('bad')));
    expect(
      () => fmtClient.get(Uri.parse('https://x.test/a')),
      throwsA(isA<ApiException>()
          .having((e) => e.rawDetail, 'rawDetail', 'format_exception')),
    );
  });

  test('maps unknown errors through friendlyErrorMessage', () async {
    final client =
        buildClient(MockClient((_) async => throw StateError('weird')));
    expect(
      () => client.get(Uri.parse('https://x.test/a')),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 0)),
    );
  });

  test('throws when no access token is stored', () async {
    when(() => storage.read(key: 'access_token'))
        .thenAnswer((_) async => null);
    final client =
        buildClient(MockClient((_) async => http.Response('{}', 200)));
    expect(() => client.get(Uri.parse('https://x.test/a')),
        throwsA(isA<ApiException>()));
  });

  group('401 refresh-retry', () {
    test('refreshes the token and retries once on 401', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-1');
      when(() => storage.write(key: 'access_token', value: 'token-2'))
          .thenAnswer((_) async {});

      var calls = 0;
      final client = buildClient(MockClient((req) async {
        if (req.url.path.endsWith('/refresh')) {
          return http.Response(jsonEncode({'access_token': 'token-2'}), 200);
        }
        calls++;
        if (calls == 1) return http.Response('{}', 401);
        expect(req.headers['Authorization'], 'Bearer token-2');
        return http.Response('{"ok":1}', 200);
      }));

      // After refresh the client re-reads the token.
      var reads = 0;
      when(() => storage.read(key: 'access_token')).thenAnswer((_) async {
        reads++;
        return reads == 1 ? 'token-1' : 'token-2';
      });

      final res = await client.get(Uri.parse('https://x.test/a'));
      expect(res.statusCode, 200);
      verify(() => storage.write(key: 'access_token', value: 'token-2'))
          .called(1);
    });

    test('returns the 401 when the refresh fails', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);
      final client = buildClient(
          MockClient((_) async => http.Response('{"detail":"expired"}', 401)));
      expect(
        () => client.get(Uri.parse('https://x.test/a')),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });
  });

  group('refreshToken', () {
    test('returns false without a refresh token', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);
      final client =
          buildClient(MockClient((_) async => http.Response('{}', 200)));
      expect(await client.refreshToken(), isFalse);
    });

    test('posts the refresh token and stores the new access token', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-1');
      when(() => storage.write(key: 'access_token', value: 'token-2'))
          .thenAnswer((_) async {});

      late http.Request seen;
      final client = buildClient(MockClient((req) async {
        seen = req;
        return http.Response(jsonEncode({'access_token': 'token-2'}), 200);
      }));

      expect(await client.refreshToken(), isTrue);
      expect(seen.url.toString(), '$BASE_URL/refresh');
      expect(jsonDecode(seen.body)['refresh_token'], 'refresh-1');
    });

    test('returns false on non-200 or network errors', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'refresh-1');

      final rejected =
          buildClient(MockClient((_) async => http.Response('{}', 403)));
      expect(await rejected.refreshToken(), isFalse);

      final broken = buildClient(
          MockClient((_) async => throw const SocketException('down')));
      expect(await broken.refreshToken(), isFalse);
    });
  });

  test('postMultipart assembles fields, files and auth header', () async {
    late http.MultipartRequest seen;
    final mock = MockClient((req) async => http.Response('{}', 200));
    // MockClient flattens multipart requests; use a StreamedResponse-based
    // client instead to capture the request object itself.
    final client = CustomHttpClient(
      httpClient: _CapturingClient((req) {
        seen = req as http.MultipartRequest;
      }),
      storage: storage,
    );

    final res = await client.postMultipart(
      Uri.parse('https://x.test/upload'),
      fields: {'kind': 'pfp'},
      buildFiles: () async => [
        http.MultipartFile.fromString('file', 'binary', filename: 'a.png'),
      ],
    );

    expect(res.statusCode, 200);
    expect(seen.fields, {'kind': 'pfp'});
    expect(seen.files.single.filename, 'a.png');
    expect(seen.headers['Authorization'], 'Bearer token-1');
    mock.close();
  });
}

class _CapturingClient extends http.BaseClient {
  final void Function(http.BaseRequest) onSend;
  _CapturingClient(this.onSend);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    onSend(request);
    return http.StreamedResponse(Stream.value(utf8.encode('{}')), 200);
  }
}

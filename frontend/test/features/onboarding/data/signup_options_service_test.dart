import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:linkup/features/onboarding/data/signup_options_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final remoteJson = jsonEncode({
    'version': 3,
    'programs': [
      {'id': 'mtech', 'label': 'MTech', 'years': 2},
    ],
  });

  test('fetches from remote, caches the body and etag', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SignupOptionsService(
      client: MockClient((req) async {
        expect(req.url.host, 'raw.githubusercontent.com');
        return http.Response(remoteJson, 200, headers: {'etag': 'W/"abc"'});
      }),
    );

    final config = await service.loadSignupOptions();
    expect(config.version, 3);
    expect(config.programs.single.id, 'mtech');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('signup_options_cache_json'), remoteJson);
    expect(prefs.getString('signup_options_cache_etag'), 'W/"abc"');
  });

  test('uses fresh cache without hitting the network', () async {
    SharedPreferences.setMockInitialValues({
      'signup_options_cache_json': remoteJson,
      'signup_options_cache_fetched_at':
          DateTime.now().millisecondsSinceEpoch,
    });
    final service = SignupOptionsService(
      client: MockClient((_) async => fail('network should not be hit')),
    );

    final config = await service.loadSignupOptions();
    expect(config.version, 3);
  });

  test('forceRefresh with 304 reuses the cached JSON', () async {
    SharedPreferences.setMockInitialValues({
      'signup_options_cache_json': remoteJson,
      'signup_options_cache_etag': 'W/"abc"',
      'signup_options_cache_fetched_at':
          DateTime.now().millisecondsSinceEpoch,
    });
    final service = SignupOptionsService(
      client: MockClient((req) async {
        expect(req.headers['If-None-Match'], 'W/"abc"');
        return http.Response('', 304);
      }),
    );

    final config = await service.loadSignupOptions(forceRefresh: true);
    expect(config.version, 3);
  });

  test('falls back to stale cache when the network fails', () async {
    SharedPreferences.setMockInitialValues({
      'signup_options_cache_json': remoteJson,
      'signup_options_cache_fetched_at': 0, // stale
    });
    final service = SignupOptionsService(
      client: MockClient((_) async => throw Exception('offline')),
    );
    expect((await service.loadSignupOptions()).version, 3);
  });

  test('with no cache and no network falls back to the bundled asset or defaults',
      () async {
    SharedPreferences.setMockInitialValues({});
    final service = SignupOptionsService(
      client: MockClient((_) async => throw Exception('offline')),
    );
    final config = await service.loadSignupOptions();
    // Bundled asset in this repo defines the program list; whatever loads,
    // the config must be non-empty and usable.
    expect(config.programs, isNotEmpty);
  });

  test('non-200/304 response falls through to defaults when no cache',
      () async {
    SharedPreferences.setMockInitialValues({});
    final service = SignupOptionsService(
      client: MockClient((_) async => http.Response('nope', 500)),
    );
    final config = await service.loadSignupOptions();
    expect(config.programs, isNotEmpty);
  });
}

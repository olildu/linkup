import 'dart:convert';

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/features/discovery/data/swipe_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  late MockCustomHttpClient client;
  late SwipeRemoteDatasource ds;

  setUpAll(registerCommonFallbacks);
  setUp(() {
    client = MockCustomHttpClient();
    ds = SwipeRemoteDatasource(client);
  });

  test('right swipe posts to /swipe/right and returns the match payload',
      () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/swipe/right'));
      expect(jsonDecode(invocation.namedArguments[#body])['liked_id'], '7');
      return http.Response(jsonEncode({'match': true}), 200);
    });

    expect(await ds.swipe(7, CardSwiperDirection.right), {'match': true});
  });

  test('left swipe posts to /swipe/left and short-circuits to no match',
      () async {
    when(() => client.post(any(), body: any(named: 'body')))
        .thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/swipe/left'));
      return http.Response('{}', 200);
    });

    expect(await ds.swipe(7, CardSwiperDirection.left), {'match': false});
  });
}

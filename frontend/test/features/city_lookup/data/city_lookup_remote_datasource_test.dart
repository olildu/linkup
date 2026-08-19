import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/features/city_lookup/data/city_lookup_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';

void main() {
  setUpAll(registerCommonFallbacks);

  test('searchCities returns the list on 200 and throws otherwise', () async {
    final client = MockCustomHttpClient();
    final ds = CityLookupRemoteDatasource(client);

    when(() => client.get(any())).thenAnswer((invocation) async {
      final uri = invocation.positionalArguments.single as Uri;
      expect(uri.path, endsWith('/locations/india/search/del'));
      return http.Response(jsonEncode(['Delhi', 'Dehradun']), 200);
    });
    expect(await ds.searchCities('del'), ['Delhi', 'Dehradun']);

    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('{}', 500));
    expect(() => ds.searchCities('del'), throwsException);
  });
}

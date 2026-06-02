import 'dart:convert';
import 'dart:developer';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';

class CityLookupRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'CityLookupRemoteDatasource';

  CityLookupRemoteDatasource(this._client);

  Future<List<String>> searchCities(String query) async {
    final response = await _client.get(
      Uri.parse('$BASE_URL/locations/india/search/$query'),
    );
    log('City search status: ${response.statusCode}', name: _tag);
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<String>();
    }
    throw Exception('City search failed: ${response.statusCode}');
  }
}

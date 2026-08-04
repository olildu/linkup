import 'dart:convert';
import 'dart:developer';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/data/models/chats_connection_model.dart';
import 'package:linkup/data/models/match_candidate_model.dart';
import 'package:linkup/data/models/matches_connection_model.dart';

class MatchRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'MatchRemoteDatasource';

  MatchRemoteDatasource(this._client);

  Future<List<MatchCandidateModel>> getMatchUsers({bool refresh = false}) async {
    final response = await _client.get(
      Uri.parse('$BASE_URL/matches/get-matches${refresh ? '?refresh=true' : ''}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['matches'] as List)
          .map((j) => MatchCandidateModel.fromJson(j))
          .toList();
    }
    log('getMatchUsers error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to fetch matches: ${response.statusCode}');
  }

  Future<({List<MatchesConnectionModel> matches, List<ChatsConnectionModel> chats})>
      getConnections() async {
    final response = await _client.get(Uri.parse('$BASE_URL/matches/get-connections'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('Connections: $data', name: _tag);
      return (
        matches: (data['matches'] as List)
            .map((j) => MatchesConnectionModel.fromJson(j))
            .toList(),
        chats: (data['chats'] as List)
            .map((j) => ChatsConnectionModel.fromJson(j))
            .toList(),
      );
    }
    log('getConnections error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to fetch connections: ${response.statusCode}');
  }
}

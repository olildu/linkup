import 'dart:convert';
import 'dart:developer';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/data/models/likes_you_response_model.dart';

class LikesRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'LikesRemoteDatasource';

  LikesRemoteDatasource(this._client);

  Future<LikesYouResponseModel> getReceivedLikes({int offset = 0}) async {
    final response = await _client.get(
      Uri.parse('$BASE_URL/likes/received?offset=$offset'),
    );
    if (response.statusCode == 200) {
      return LikesYouResponseModel.fromJson(jsonDecode(response.body));
    }
    log('getReceivedLikes error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to fetch received likes: ${response.statusCode}');
  }

  Future<int> getLikesCount() async {
    final response = await _client.get(Uri.parse('$BASE_URL/likes/count'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['total_count'] as int;
    }
    log('getLikesCount error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to fetch likes count: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> likeBack(int likerId) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/likes/$likerId/like-back'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    log('likeBack error: ${response.statusCode}', name: _tag);
    throw Exception('Failed to like back: ${response.statusCode}');
  }

  Future<void> passLike(int likerId) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/likes/$likerId/pass'),
    );
    if (response.statusCode != 200) {
      log('passLike error: ${response.statusCode}', name: _tag);
      throw Exception('Failed to pass: ${response.statusCode}');
    }
  }
}

import 'dart:convert';

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';

class SwipeRemoteDatasource {
  final CustomHttpClient _client;

  SwipeRemoteDatasource(this._client);

  Future<Map<String, dynamic>> swipe(int likedId, CardSwiperDirection direction) async {
    final endpoint = direction == CardSwiperDirection.left ? '/swipe/left' : '/swipe/right';
    final response = await _client.post(
      Uri.parse('$BASE_URL$endpoint'),
      body: jsonEncode({'liked_id': likedId.toString()}),
    );
    if (direction == CardSwiperDirection.right) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    return {'match': false};
  }
}

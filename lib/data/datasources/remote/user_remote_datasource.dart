import 'dart:convert';
import 'dart:developer';

import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/data/models/match_candidate_model.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/data/models/user_model.dart';
import 'package:linkup/data/models/user_preference_model.dart';

class UserRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'UserRemoteDatasource';

  UserRemoteDatasource(this._client);

  Future<UserModel> getProfile() async {
    final response = await _client.get(Uri.parse('$BASE_URL/me'));
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch profile: ${response.statusCode}');
  }

  Future<MatchCandidateModel> getOtherProfile(int userId) async {
    final response = await _client.get(Uri.parse('$BASE_URL/user/get/detail/$userId'));
    if (response.statusCode == 200) {
      return MatchCandidateModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch user $userId: ${response.statusCode}');
  }

  Future<void> updateProfile(UpdateMetadataModel data, {bool updatePfp = false}) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/user/update/metadata?update_pfp=$updatePfp'),
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
    log('Profile updated: ${response.body}', name: _tag);
  }

  Future<UserPreferenceModel> getPreference() async {
    final response = await _client.get(Uri.parse('$BASE_URL/user/get/preferences'));
    if (response.statusCode == 200) {
      return UserPreferenceModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch preferences: ${response.statusCode}');
  }

  Future<void> updatePreference(UserPreferenceModel preference) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/user/update/preferences'),
      body: jsonEncode(preference.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update preferences: ${response.statusCode}');
    }
  }

  Future<void> deleteAccount() async {
    final response = await _client.delete(Uri.parse('$BASE_URL/user/delete'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }

  Future<void> blockUser(int userId) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/user/block'),
      body: jsonEncode({'blocked_user_id': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to block user: ${response.statusCode}');
    }
    log('User $userId blocked', name: _tag);
  }

  Future<void> reportUser(int userId, String reason) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/user/report'),
      body: jsonEncode({'reported_user_id': userId, 'reason': reason}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to report user: ${response.statusCode}');
    }
    log('User $userId reported', name: _tag);
  }
}

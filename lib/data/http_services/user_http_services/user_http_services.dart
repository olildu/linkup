import 'dart:convert';
import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:linkup/data/clients/custom_http_client.dart';
import 'package:linkup/data/models/match_candidate_model.dart';
import 'package:linkup/data/models/update_metadata_model.dart';
import 'package:linkup/data/models/user_model.dart';
import 'package:linkup/data/models/user_preference_model.dart';
import 'package:linkup/presentation/constants/global_constants.dart';

class UserHttpServices {
  static final CustomHttpClient _client = GetIt.instance<CustomHttpClient>();

  Future<bool> deleteAccount() async {
    final response = await _client.delete(Uri.parse("$BASE_URL/user/delete"));

    if (response.statusCode == 200) {
      return true;
    } else {
      log('Error deleting account: ${response.statusCode}');
      throw Exception('Failed to delete account');
    }
  }

  Future<UserModel> getProfileSettings() async {
    final response = await _client.get(Uri.parse("$BASE_URL/me"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return UserModel.fromJson(jsonData);
    } else {
      print('Error: ${response.statusCode}');
      throw Exception(
        'Failed to fetch. Status: ${response.statusCode} Server-Response: ${response.body}',
      );
    }
  }

  Future<MatchCandidateModel> getOtherProfile({required int userId}) async {
    final response = await _client.get(Uri.parse("$BASE_URL/user/get/detail/$userId"));

    if (response.statusCode == 200) {
      log(json.decode(response.body).toString());
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return MatchCandidateModel.fromJson(jsonData);
    } else {
      print('Error: ${response.statusCode}');
      throw Exception(
        'Failed to fetch. Status: ${response.statusCode} Server-Response: ${response.body}',
      );
    }
  }

  Future<UserPreferenceModel> getUserPreference() async {
    final response = await _client.get(Uri.parse("$BASE_URL/user/get/preferences"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return UserPreferenceModel.fromJson(jsonData);
    } else {
      print('Error: ${response.statusCode}');
      throw Exception(
        'Failed to fetch. Status: ${response.statusCode} Server-Response: ${response.body}',
      );
    }
  }

  Future<void> updateUserPreference({required UserPreferenceModel userPreference}) async {
    var body = userPreference.toJson();

    final response = await _client.post(
      Uri.parse("$BASE_URL/user/update/preferences"),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      log('User preferences updated successfully: $jsonData');
    } else {
      print('Error: ${response.statusCode}');
      throw Exception(
        'Failed to fetch. Status: ${response.statusCode} Server-Response: ${response.body}',
      );
    }
  }

  Future<void> updateUserProfile({
    required UpdateMetadataModel userUpdatedModel,
    bool updatePfp = false,
  }) async {
    var body = userUpdatedModel.toJson();

    final response = await _client.post(
      Uri.parse("$BASE_URL/user/update/metadata?update_pfp=$updatePfp"),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      log('User preferences updated successfully: $jsonData');
    } else {
      log('Error: ${response.statusCode}');
      throw Exception(
        'Failed to fetch. Status: ${response.statusCode} Server-Response: ${response.body}',
      );
    }
  }

  Future<void> blockUser({required int userId}) async {
    final response = await _client.post(
      Uri.parse("$BASE_URL/user/block"),
      body: json.encode({"blocked_user_id": userId}),
    );

    if (response.statusCode == 200) {
      log('User $userId blocked successfully');
    } else {
      log('Error blocking user: ${response.statusCode}');
      throw Exception('Failed to block user');
    }
  }

  Future<void> reportUser({required int userId, required String reason}) async {
    final response = await _client.post(
      Uri.parse("$BASE_URL/user/report"),
      body: json.encode({"reported_user_id": userId, "reason": reason}),
    );

    if (response.statusCode == 200) {
      log('User $userId reported successfully');
    } else {
      log('Error reporting user: ${response.statusCode}');
      throw Exception('Failed to report user');
    }
  }
}

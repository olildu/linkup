import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/data/models/update_metadata_model.dart';

class AuthRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'AuthRemoteDatasource';

  AuthRemoteDatasource(this._client);

  String _extractDetail(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return body['detail']?.toString() ?? '';
      }
    } catch (_) {}
    return '';
  }

  /// Maps a failed pre-auth response (login/signup/otp/reset — these run
  /// before an access token exists, so they can't go through
  /// [CustomHttpClient]) to a friendly [ApiException].
  Never _throwFriendly(http.Response response) {
    final detail = _extractDetail(response);
    throw ApiException(
      statusCode: response.statusCode,
      message: friendlyFromResponse(response.statusCode, detail),
      rawDetail: detail,
    );
  }

  Future<({String accessToken, String refreshToken, int userId})> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/token'),
      body: {'username': email, 'password': password},
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    log('Login status: ${response.statusCode}', name: _tag);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (
        accessToken: body['access_token'] as String,
        refreshToken: body['refresh_token'] as String,
        userId: body['user_id'] as int,
      );
    }
    if (response.statusCode == 404) {
      throw AccountNotFoundException(friendlyFromResponse(404, _extractDetail(response)));
    }
    _throwFriendly(response);
  }

  Future<int> sendEmailOTP(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/verify-email?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );
      log('OTP status: ${response.statusCode}', name: _tag);
      return response.statusCode;
    } catch (e) {
      log('sendEmailOTP error: $e', name: _tag);
      return 500;
    }
  }

  Future<Map<String, dynamic>> verifyEmailOTP(
    String email,
    int otp,
    EmailOTPSubject subject,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'subject': subject.value}),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    _throwFriendly(response);
  }

  Future<({String accessToken, String refreshToken, int userId})> register(
    String emailHash,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email_hash': emailHash, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return (
          accessToken: body['access_token'] as String,
          refreshToken: body['refresh_token'] as String,
          userId: body['user_id'] as int,
        );
      }
    }
    _throwFriendly(response);
  }

  Future<bool> resetPassword(String emailHash, String password) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email_hash': emailHash, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['status'] == 'success';
    }
    _throwFriendly(response);
  }

  Future<bool> completeProfile(UpdateMetadataModel data) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/register'),
      body: jsonEncode(data.toJson()),
    );
    return jsonDecode(response.body)['msg'] != null;
  }
}

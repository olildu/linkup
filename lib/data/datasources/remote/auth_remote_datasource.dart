import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/enums/otp_subject_enum.dart';
import 'package:linkup/core/network/custom_http_client.dart';
import 'package:linkup/data/models/update_metadata_model.dart';

class AuthRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'AuthRemoteDatasource';

  AuthRemoteDatasource(this._client);

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
    throw Exception('Login failed: ${response.statusCode}');
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
    throw Exception(_client.handleResponse(response));
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
    final error = jsonDecode(response.body);
    throw Exception('Signup failed: ${error['detail'] ?? 'Unknown error'}');
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
    final error = jsonDecode(response.body);
    throw Exception('Reset failed: ${error['detail'] ?? 'Unknown error'}');
  }

  Future<bool> completeProfile(UpdateMetadataModel data) async {
    final response = await _client.post(
      Uri.parse('$BASE_URL/register'),
      body: jsonEncode(data.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body)['msg'] != null;
    }
    final error = jsonDecode(response.body);
    throw Exception('Profile completion failed: ${error['detail'] ?? 'Unknown error'}');
  }
}

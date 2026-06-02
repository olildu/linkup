import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/constants/app_constants.dart';

class CustomHttpClient {
  final _storage = GetIt.instance<FlutterSecureStorage>();

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _execute(() => _withAuth((token) => http.get(uri, headers: _headers(token, headers))));

  Future<http.Response> post(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _execute(() => _withAuth((token) => http.post(uri, headers: _headers(token, headers), body: body)));

  Future<http.Response> delete(Uri uri, {Map<String, String>? headers, Object? body}) =>
      _execute(() => _withAuth((token) => http.delete(uri, headers: _headers(token, headers), body: body)));

  Future<http.Response> postMultipart(
    Uri uri, {
    Map<String, String>? headers,
    required Map<String, String> fields,
    required Future<List<http.MultipartFile>> Function() buildFiles,
  }) =>
      _execute(() => _withAuth((token) async {
            final req = http.MultipartRequest('POST', uri)
              ..headers.addAll({'Authorization': 'Bearer $token', ...?headers})
              ..fields.addAll(fields)
              ..files.addAll(await buildFiles());
            return http.Response.fromStream(await req.send());
          }));

  Future<http.Response> _execute(Future<http.Response> Function() request) async {
    try {
      return handleResponse(await request());
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception("Couldn't find the requested service.");
    } on FormatException {
      throw Exception('Bad response format from server.');
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  http.Response handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return response;

    String message = 'Something went wrong (Error ${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail']?.toString() ?? '';

      if (detail.contains('duplicate key') && detail.contains('users_email_key')) {
        message = 'This email is already registered. Please log in.';
      } else if (detail.contains('OTP verification failed')) {
        message = 'The code you entered is incorrect. Please try again.';
      } else if (detail.contains('Password must contain at')) {
        message = 'Password must contain at least one uppercase letter, one lowercase letter, and one symbol.';
      } else if (detail.contains('Face not detected')) {
        message = "We couldn't detect a clear face in your photo.";
      } else if (response.statusCode == 401) {
        message = 'Session expired. Please log in again.';
      } else if (response.statusCode == 500) {
        message = 'Server maintenance. Please try again in a few minutes.';
      } else if (detail.isNotEmpty) {
        message = detail;
      }
    } catch (_) {}

    throw Exception(message);
  }

  Future<http.Response> _withAuth(Future<http.Response> Function(String) request) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) throw Exception('Unauthorized. Please log in.');

    http.Response response = await request(token);
    if (response.statusCode == 401) {
      if (await refreshToken()) {
        token = await _storage.read(key: 'access_token');
        response = await request(token!);
      }
    }
    return response;
  }

  Map<String, String> _headers(String token, Map<String, String>? extra) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        ...?extra,
      };

  Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$BASE_URL/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );
      if (res.statusCode == 200) {
        await _storage.write(key: 'access_token', value: jsonDecode(res.body)['access_token']);
        return true;
      }
    } catch (_) {}
    return false;
  }
}

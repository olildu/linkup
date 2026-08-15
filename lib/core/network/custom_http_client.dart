import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/errors/api_exception.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';

class CustomHttpClient {
  final _storage = GetIt.instance<FlutterSecureStorage>();

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _execute(
        () => _withAuth(
          (token) => http.get(uri, headers: _headers(token, headers)),
        ),
      );

  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _execute(
    () => _withAuth(
      (token) => http.post(uri, headers: _headers(token, headers), body: body),
    ),
  );

  Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _execute(
    () => _withAuth(
      (token) =>
          http.delete(uri, headers: _headers(token, headers), body: body),
    ),
  );

  Future<http.Response> postMultipart(
    Uri uri, {
    Map<String, String>? headers,
    required Map<String, String> fields,
    required Future<List<http.MultipartFile>> Function() buildFiles,
  }) => _execute(
    () => _withAuth((token) async {
      final req = http.MultipartRequest('POST', uri)
        ..headers.addAll({'Authorization': 'Bearer $token', ...?headers})
        ..fields.addAll(fields)
        ..files.addAll(await buildFiles());
      return http.Response.fromStream(await req.send());
    }),
  );

  Future<http.Response> _execute(
    Future<http.Response> Function() request,
  ) async {
    try {
      return handleResponse(await request());
    } on SwipeLimitException {
      rethrow;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection. Please check your network.',
        rawDetail: 'socket_exception',
      );
    } on HttpException {
      throw ApiException(
        statusCode: 0,
        message: "Couldn't find the requested service.",
        rawDetail: 'http_exception',
      );
    } on FormatException {
      throw ApiException(
        statusCode: 0,
        message: 'Unexpected response from the server. Please try again.',
        rawDetail: 'format_exception',
      );
    } catch (e) {
      throw ApiException(
        statusCode: 0,
        message: friendlyErrorMessage(e),
        rawDetail: e.toString(),
      );
    }
  }

  http.Response handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    String detail = '';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      detail = body['detail']?.toString() ?? '';
    } catch (_) {}

    final message = friendlyFromResponse(response.statusCode, detail);

    if (response.statusCode == 429) throw SwipeLimitException(message);
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      rawDetail: detail,
    );
  }

  Future<http.Response> _withAuth(
    Future<http.Response> Function(String) request,
  ) async {
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
        await _storage.write(
          key: 'access_token',
          value: jsonDecode(res.body)['access_token'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }
}

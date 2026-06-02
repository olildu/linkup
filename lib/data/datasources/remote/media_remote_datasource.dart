import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:linkup/core/constants/app_constants.dart';
import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/core/network/custom_http_client.dart';

class MediaRemoteDatasource {
  final CustomHttpClient _client;
  static const _tag = 'MediaRemoteDatasource';

  MediaRemoteDatasource(this._client);

  Future<Map<String, dynamic>> uploadChatMedia(File file, MessageType mediaType) async {
    final response = await _client.postMultipart(
      Uri.parse('$BASE_URL/upload/media'),
      fields: {'media_type': mediaType.name},
      buildFiles: () async => [await http.MultipartFile.fromPath('file', file.path)],
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('uploadChatMedia: $data', name: _tag);
      return data;
    }
    throw Exception('Chat media upload failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> uploadUserMedia(File file, MessageType mediaType) async {
    final response = await _client.postMultipart(
      Uri.parse('$BASE_URL/upload/media-user'),
      fields: {'media_type': mediaType.name},
      buildFiles: () async => [await http.MultipartFile.fromPath('file', file.path)],
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('User media upload failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> uploadPfp(File file, MessageType mediaType) async {
    final response = await _client.postMultipart(
      Uri.parse('$BASE_URL/upload/media-user-pfp'),
      fields: {'media_type': mediaType.name},
      buildFiles: () async => [await http.MultipartFile.fromPath('file', file.path)],
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('uploadPfp: $data', name: _tag);
      return data;
    }
    throw Exception('PFP upload failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> uploadPfpFromUrl(String imageUrl) async {
    final response = await _client.postMultipart(
      Uri.parse('$BASE_URL/upload/media-user-pfp-from-url'),
      fields: {'image_url': imageUrl},
      buildFiles: () async => [],
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      log('uploadPfpFromUrl: $data', name: _tag);
      return data;
    }
    throw Exception('PFP from URL upload failed: ${response.statusCode}');
  }
}

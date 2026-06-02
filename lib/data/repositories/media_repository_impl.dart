import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/data/datasources/remote/media_remote_datasource.dart';
import 'package:linkup/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDatasource _datasource;

  const MediaRepositoryImpl(this._datasource);

  @override
  Future<Map<String, dynamic>> uploadChatMedia(File file, MessageType mediaType) =>
      _datasource.uploadChatMedia(file, mediaType);

  @override
  Future<Map<String, dynamic>> uploadUserMedia(File file, MessageType mediaType) =>
      _datasource.uploadUserMedia(file, mediaType);

  @override
  Future<Map<String, dynamic>> uploadPfp(File file, MessageType mediaType) =>
      _datasource.uploadPfp(file, mediaType);

  @override
  Future<Map<String, dynamic>> uploadPfpFromUrl(String imageUrl) =>
      _datasource.uploadPfpFromUrl(imageUrl);
}

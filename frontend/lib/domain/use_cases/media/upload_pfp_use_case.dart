import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/domain/repositories/media_repository.dart';

class UploadPfpUseCase {
  final MediaRepository _repository;
  const UploadPfpUseCase(this._repository);

  Future<Map<String, dynamic>> call(File file, MessageType mediaType) =>
      _repository.uploadPfp(file, mediaType);
}

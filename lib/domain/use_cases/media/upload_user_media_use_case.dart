import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/domain/repositories/media_repository.dart';

class UploadUserMediaUseCase {
  final MediaRepository _repository;
  const UploadUserMediaUseCase(this._repository);

  Future<Map<String, dynamic>> call(File file, MessageType mediaType) =>
      _repository.uploadUserMedia(file, mediaType);
}

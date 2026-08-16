import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';
import 'package:linkup/features/messaging/domain/chat_repository.dart';

class UploadChatMediaUseCase {
  final ChatRepository _repository;
  const UploadChatMediaUseCase(this._repository);

  Future<Map<String, dynamic>> call(File file, MessageType mediaType) =>
      _repository.uploadChatMedia(file, mediaType);
}

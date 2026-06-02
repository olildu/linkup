import 'dart:io';

import 'package:linkup/core/enums/message_type_enum.dart';

abstract class MediaRepository {
  Future<Map<String, dynamic>> uploadChatMedia(File file, MessageType mediaType);
  Future<Map<String, dynamic>> uploadUserMedia(File file, MessageType mediaType);
  Future<Map<String, dynamic>> uploadPfp(File file, MessageType mediaType);
  Future<Map<String, dynamic>> uploadPfpFromUrl(String imageUrl);
}

import 'package:linkup/core/enums/message_type_enum.dart';

class MediaMessageEntity {
  final String fileKey;
  final MessageType mediaType;
  final String blurhashText;
  final Map<String, dynamic> metadata;

  const MediaMessageEntity({
    required this.fileKey,
    required this.mediaType,
    required this.blurhashText,
    required this.metadata,
  });
}

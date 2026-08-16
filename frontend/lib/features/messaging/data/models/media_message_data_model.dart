import 'package:linkup/core/enums/message_type_enum.dart';

class MediaMessageData {
  final String fileKey;
  final MessageType mediaType;
  final String blurhashText;
  final Map<String, dynamic> metadata;

  MediaMessageData({
    required this.fileKey,
    required this.mediaType,
    required this.blurhashText,
    required this.metadata,
  });

  factory MediaMessageData.fromJson(Map<String, dynamic> json) {
    return MediaMessageData(
      fileKey: json['file_key'] as String,
      mediaType: MessageType.values.firstWhere(
        (e) => e.name == json['media_type'],
        orElse: () => MessageType.image,
      ),
      blurhashText: json['blurhash_text'] ?? '',
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_key': fileKey,
      'mediaType': mediaType.name,
      'blurhashText': blurhashText,
      'metadata': metadata,
    };
  }
}

enum MessageType { text, voice, image }

MessageType messageTypeFromString(String? type) {
  switch (type) {
    case 'voice':
      return MessageType.voice;
    case 'image':
      return MessageType.image;
    default:
      return MessageType.text;
  }
}

bool containsOnlyEmojis(String inputString) {
  if (inputString.isEmpty) {
    return false;
  }

  const String baseEmojiRanges =
      r'\u{1F600}-\u{1F64F}'
      r'\u{1F300}-\u{1F5FF}'
      r'\u{1F680}-\u{1F6FF}'
      r'\u{1F900}-\u{1F9FF}'
      r'\u{1FA70}-\u{1FAFF}'
      r'\u{2600}-\u{26FF}'
      r'\u{2700}-\u{27BF}';

  const String variationSelectors = r'\u{FE0E}\u{FE0F}';
  const String skinToneModifiers = r'\u{1F3FB}-\u{1F3FF}';
  const String regionalIndicators = r'\u{1F1E6}-\u{1F1FF}';
  const String zwj = r'\u{200D}';
  const String pBase = '[$baseEmojiRanges]';
  const String pModifiedEmoji =
      '$pBase(?:[$variationSelectors])?(?:[$skinToneModifiers])?';
  const String pFlag = '(?:[$regionalIndicators]{2})';

  const String pZwjSequence = '(?:$pModifiedEmoji(?:$zwj$pModifiedEmoji)+)';

  final emojiPattern = RegExp(
    r'^(?:'
    '$pZwjSequence|'
    '$pFlag|'
    '$pModifiedEmoji'
    r')+$',
    unicode: true,
  );

  return emojiPattern.hasMatch(inputString);
}

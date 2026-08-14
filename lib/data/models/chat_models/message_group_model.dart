class MessageGroupModel {
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isOnlyMessageInGroup;
  final int groupSize;
  final int positionInGroup;
  final bool prevMessageEmoji;
  final bool nextMessageEmoji;

  MessageGroupModel({
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.isOnlyMessageInGroup,
    required this.groupSize,
    required this.positionInGroup,
    this.prevMessageEmoji = false,
    this.nextMessageEmoji = false,
  });
}

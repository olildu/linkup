import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/data/models/chat_models/message_group_model.dart';

BorderRadius getBorderRadius({
  required MessageGroupModel groupInfo,
  required bool isSentByMe,
  required bool isOnlyEmoji,
  required bool containsReply,
}) {
  final Radius largeRadius = Radius.circular(20.r);
  final Radius smallRadius = Radius.circular(4.r);

  if (isOnlyEmoji || containsReply) {
    return BorderRadius.all(largeRadius);
  }
  if (groupInfo.isOnlyMessageInGroup) {
    return BorderRadius.all(largeRadius);
  }
  final shouldUseFullRadius = _shouldUseFullRadius(groupInfo);
  if (shouldUseFullRadius) {
    return BorderRadius.all(largeRadius);
  }
  if (isSentByMe) {
    return _getSentMessageBorderRadius(groupInfo, largeRadius, smallRadius);
  } else {
    return _getReceivedMessageBorderRadius(groupInfo, largeRadius, smallRadius);
  }
}

bool _shouldUseFullRadius(MessageGroupModel groupInfo) {
  if (groupInfo.prevMessageEmoji && groupInfo.nextMessageEmoji) {
    return true;
  }
  if (groupInfo.prevMessageEmoji && groupInfo.isLastInGroup) {
    return true;
  }
  if (groupInfo.nextMessageEmoji && groupInfo.isFirstInGroup) {
    return true;
  }
  return false;
}

BorderRadius _getSentMessageBorderRadius(
  MessageGroupModel groupInfo,
  Radius largeRadius,
  Radius smallRadius,
) {
  if (groupInfo.isFirstInGroup) {
    return BorderRadius.only(
      topLeft: largeRadius,
      topRight: largeRadius,
      bottomLeft: largeRadius,
      bottomRight: smallRadius,
    );
  } else if (groupInfo.isLastInGroup) {
    return BorderRadius.only(
      topLeft: largeRadius,
      topRight: smallRadius,
      bottomLeft: largeRadius,
      bottomRight: largeRadius,
    );
  } else {
    return BorderRadius.only(
      topLeft: largeRadius,
      topRight: smallRadius,
      bottomLeft: largeRadius,
      bottomRight: smallRadius,
    );
  }
}

BorderRadius _getReceivedMessageBorderRadius(
  MessageGroupModel groupInfo,
  Radius largeRadius,
  Radius smallRadius,
) {
  if (groupInfo.isFirstInGroup) {
    return BorderRadius.only(
      topLeft: largeRadius,
      topRight: largeRadius,
      bottomLeft: smallRadius,
      bottomRight: largeRadius,
    );
  } else if (groupInfo.isLastInGroup) {
    return BorderRadius.only(
      topLeft: smallRadius,
      topRight: largeRadius,
      bottomLeft: largeRadius,
      bottomRight: largeRadius,
    );
  } else {
    return BorderRadius.only(
      topLeft: smallRadius,
      topRight: largeRadius,
      bottomLeft: smallRadius,
      bottomRight: largeRadius,
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get_it/get_it.dart';
import 'package:linkup/data/models/chat_models/message_model.dart';
import 'package:linkup/presentation/components/chat_page/reply_renderer.dart';
import 'package:linkup/presentation/constants/colors.dart';
import 'package:linkup/presentation/screens/full_screen_image_page.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

class MessageRenderer extends StatelessWidget {
  final Message message;
  final List<Message> messages;
  final bool isSentByMe;
  final BorderRadius messageBorderRadius;
  final Color color;
  final bool isOnlyEmoji;

  const MessageRenderer({
    super.key,
    required this.message,
    required this.messages,
    required this.isSentByMe,
    required this.messageBorderRadius,
    required this.color,
    required this.isOnlyEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final bool replyIdExists = message.replyID != null;
    final replyMessage = replyIdExists
        ? messages.firstWhere(
            (m) => m.id == message.replyID,
            orElse: () => Message(
              id: '',
              message: '[Original message not found]',
              to: 0,
              from_: 0,
              timestamp: DateTime.now(),
              chatRoomId: 0,
            ),
          )
        : null;

    final replyColor = isOnlyEmoji
        ? Colors.transparent
        : replyMessage?.from_ == GetIt.instance<int>(instanceName: 'user_id')
        ? AppColors.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    Widget messageContentRenderer({
      required Message message,
      required BorderRadius messageBorderRadius,
      required Color color,
      required bool isOnlyEmoji,
      bool isReply = false,
    }) {
      final media = message.media;
      final textColor = isSentByMe
          ? Theme.of(context).colorScheme.onPrimaryContainer
          : Theme.of(context).colorScheme.onSecondaryContainer;

      if (media != null) {
        final mediaMetaData = media.metadata;
        final String imageUrl = mediaMetaData["file_url"];
        final String imageCacheKey = media.fileKey;
        final double height = mediaMetaData["height"] ?? 200.0;
        final double width = mediaMetaData["width"] ?? 200.0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    FullScreenImageScreen(imagePath: imageUrl),
              ),
            );
          },
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.6.sw, maxHeight: 250.h),
            width: width,
            height: height,
            decoration: BoxDecoration(borderRadius: messageBorderRadius),
            clipBehavior: Clip.antiAlias,
            child: OctoImage(
              image: CachedNetworkImageProvider(
                imageUrl,
                cacheKey: imageCacheKey,
                maxHeight: height.toInt(),
                maxWidth: width.toInt(),
              ),
              placeholderBuilder: blurHash(
                mediaMetaData["blurhash"],
              ).placeholderBuilder,
              errorBuilder: OctoError.icon(
                color: Theme.of(context).colorScheme.error,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        return Container(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          padding: isOnlyEmoji
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: messageBorderRadius,
          ),
          child: Text(
            message.message,
            maxLines: isReply ? 2 : null,
            overflow: isReply ? TextOverflow.ellipsis : null,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isOnlyEmoji ? 35.sp : 14.sp,
              color: isOnlyEmoji ? null : textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: isSentByMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        if (replyIdExists) ...[
          ReplyRenderer(
            isSentByMe: isSentByMe,
            isReversed: !isSentByMe,
            replyMessageContent: messageContentRenderer(
              message: replyMessage!,
              isReply: true,
              messageBorderRadius: BorderRadius.circular(20.r),
              color: replyColor,
              isOnlyEmoji: isOnlyEmoji,
            ),
            barColor: Theme.of(context).colorScheme.onPrimary,
          ),

          Gap(5.h),
        ],

        // Normal Media
        messageContentRenderer(
          message: message,
          messageBorderRadius: messageBorderRadius,
          color: color,
          isOnlyEmoji: isOnlyEmoji,
        ),
      ],
    );
  }
}

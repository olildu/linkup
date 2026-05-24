import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/presentation/components/chat_page/event_intro_animation.dart';
import 'package:linkup/presentation/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

Widget buildTypingIndicator({required BuildContext context, required Map imageMetaData, required String userName}) {
  final Radius largeRadius = Radius.circular(20.r);

  final BorderRadius messageBorderRadius = BorderRadius.only(topLeft: largeRadius, topRight: largeRadius, bottomLeft: largeRadius, bottomRight: largeRadius);

  final color = Color.fromARGB(255, 33, 37, 42);
  final textColor = Theme.of(context).colorScheme.onSecondaryContainer;

  return EventIntroAnimation(
    alignment: Alignment.centerLeft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipOval(
          child: OctoImage(
            image: CachedNetworkImageProvider(imageMetaData['url']),
            placeholderBuilder: blurHash(imageMetaData['blurhash']).placeholderBuilder,
            fit: BoxFit.cover,
            width: 30.r,
            height: 30.r,
          ),
        ),

        Gap(8.w),
        Container(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(color: color, borderRadius: messageBorderRadius),
          child: Text(
            '$userName is typing...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14.sp, color: textColor, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    ),
  );
}

Widget buildSeenIndicator() {
  return EventIntroAnimation(
    alignment: Alignment.centerRight,
    child: Align(
      alignment: Alignment.centerRight,
      child: Builder(
        builder: (context) => Text(
          "Seen",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10.sp, fontWeight: FontWeight.w300, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
        ),
      ),
    ),
  );
}

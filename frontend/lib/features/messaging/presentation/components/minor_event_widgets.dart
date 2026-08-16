import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/features/messaging/presentation/components/event_intro_animation.dart';
import 'package:linkup/shared_ui/theme/app_radius.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';
import 'package:linkup/shared_ui/utils/blurhash_util.dart';
import 'package:octo_image/octo_image.dart';

Widget buildTypingIndicator({
  required BuildContext context,
  required Map imageMetaData,
  required String userName,
}) {
  final BorderRadius messageBorderRadius = BorderRadius.all(
    Radius.circular(AppRadius.md),
  );

  final color = Theme.of(context).colorScheme.surfaceContainerHighest;
  final textColor = Theme.of(context).colorScheme.onSecondaryContainer;

  return EventIntroAnimation(
    alignment: Alignment.centerLeft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipOval(
          child: OctoImage(
            image: CachedNetworkImageProvider(
              imageMetaData['url'],
              cacheKey: imageMetaData['file_key'],
            ),
            placeholderBuilder: blurHash(
              imageMetaData['blurhash'],
            ).placeholderBuilder,
            fit: BoxFit.cover,
            width: 30.r,
            height: 30.r,
          ),
        ),

        Gap(AppSpacing.sm.w),
        Container(
          constraints: BoxConstraints(maxWidth: 0.75.sw),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: messageBorderRadius,
          ),
          child: Text(
            '$userName is typing...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontStyle: FontStyle.italic,
            ),
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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    ),
  );
}

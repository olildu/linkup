import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ReplyRenderer extends StatelessWidget {
  final bool isSentByMe;
  final bool isReversed;
  final Widget replyMessageContent;
  final Color barColor;
  final double barWidth;
  final double barTopPadding;
  final double barBottomPadding;
  final double barRadius;

  const ReplyRenderer({
    super.key,
    required this.isSentByMe,
    required this.isReversed,
    required this.replyMessageContent,
    required this.barColor,
    this.barWidth = 4,
    this.barTopPadding = 3,
    this.barBottomPadding = 3,
    this.barRadius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorBar = Padding(
      padding: EdgeInsets.only(
        top: barTopPadding.h,
        bottom: barBottomPadding.h,
      ),
      child: Container(
        width: barWidth,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(barRadius),
        ),
      ),
    );

    final informationText = Column(
      crossAxisAlignment: isReversed
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          isSentByMe ? "You replied" : "Replied to you",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    return IntrinsicHeight(
      child: Opacity(
        opacity: 0.8,
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Gap(13.h),
            informationText,
            Gap(5.h),
            Expanded(
              child: Row(
                children: isReversed
                    ? [
                        indicatorBar,
                        Gap(7.w),
                        Opacity(opacity: 0.6, child: replyMessageContent),
                      ]
                    : [replyMessageContent, Gap(7.w), indicatorBar],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

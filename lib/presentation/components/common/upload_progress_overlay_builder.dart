import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class UploadProgressOverlayBuilder extends StatelessWidget {
  final int current;
  final int total;
  final String message;

  const UploadProgressOverlayBuilder({
    super.key,
    required this.current,
    required this.total,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : current / total;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                ),
              ),

              Gap(12.w),

              Expanded(
                child: Text(
                  "$message $current/$total",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          Gap(14.h),

          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, animatedValue, child) {
                return LinearProgressIndicator(
                  value: animatedValue,
                  minHeight: 4.h,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

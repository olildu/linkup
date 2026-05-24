import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class InfoBuilder extends StatelessWidget {
  final String text;
  final IconData? icon;

  const InfoBuilder({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 12.0.h),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20.0.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
          if (icon != null) Gap(8.w),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}

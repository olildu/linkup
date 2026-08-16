import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/shared_ui/constants/colors.dart';
import 'package:linkup/shared_ui/theme/app_spacing.dart';

class MenuTileBuilder extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;
  final String? trailingText;
  final Widget? trailingWidget;
  final Color? titleColor;
  final Color? iconColor;
  final Color? trailingTextColor;
  final bool showBorder;
  final bool filledBackground;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double iconSize;
  final double arrowSize;
  final bool showArrow;

  const MenuTileBuilder({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingText,
    this.trailingWidget,
    this.titleColor,
    this.iconColor,
    this.trailingTextColor,
    this.showBorder = true,
    this.filledBackground = true,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 18,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.iconSize = 20,
    this.arrowSize = 16,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveBackgroundColor =
        backgroundColor ??
        (filledBackground ? theme.cardColor : Colors.transparent);
    final Color effectiveBorderColor =
        borderColor ?? AppColors.notSelected.withValues(alpha: 0.22);
    final Color effectiveIconColor = iconColor ?? theme.colorScheme.onSurface;
    final Color effectiveTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final Color effectiveTrailingTextColor =
        trailingTextColor ?? theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: Container(
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: showBorder
                ? Border.all(color: effectiveBorderColor, width: borderWidth)
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: effectiveIconColor, size: iconSize.sp),
              Gap(12.w),
              Expanded(
                child: trailingWidget != null
                    ? Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: effectiveTitleColor,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  Gap(4.h),
                                  Text(
                                    subtitle!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.sp,
                                      color:
                                          theme.textTheme.bodySmall?.color ??
                                          theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Gap(10.w),
                          trailingWidget!,
                        ],
                      )
                    : trailingText == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: effectiveTitleColor,
                            ),
                          ),
                          if (subtitle != null) ...[
                            Gap(4.h),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13.sp,
                                color:
                                    theme.textTheme.bodySmall?.color ??
                                    theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: effectiveTitleColor,
                                  ),
                                ),
                                if (subtitle != null) ...[
                                  Gap(4.h),
                                  Text(
                                    subtitle!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13.sp,
                                      color:
                                          theme.textTheme.bodySmall?.color ??
                                          theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Gap(10.w),
                          Text(
                            trailingText!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: effectiveTrailingTextColor,
                            ),
                          ),
                        ],
                      ),
              ),
              if (showArrow) ...[
                Gap(10.w),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: arrowSize.sp,
                  color: AppColors.notSelected,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

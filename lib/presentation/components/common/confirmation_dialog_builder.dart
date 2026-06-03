import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ConfirmationDialogBuilder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? content;
  final String? confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? confirmTextColor;
  final Color? confirmBackgroundColor;
  final Color? cancelTextColor;
  final List<Widget>? actions;
  final bool verticalButtons;
  final bool primaryOnTop;

  const ConfirmationDialogBuilder({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.content,
    this.confirmText,
    required this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.iconColor,
    this.iconBackgroundColor,
    this.confirmTextColor,
    this.confirmBackgroundColor,
    this.cancelTextColor,
    this.actions,
    this.verticalButtons = true,
    this.primaryOnTop = true,
  });

  /// Shows this dialog with a blurred backdrop.
  static Future<T?> show<T>(
    BuildContext context,
    ConfirmationDialogBuilder dialog, {
    double blurSigma = 20.0,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(child: dialog);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Stack(
          children: [
            // Fullscreen blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: Colors.black.withValues(alpha: 0)),
            ),
            FadeTransition(opacity: animation, child: child),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color effectiveIconColor = iconColor ?? colorScheme.error;
    final Color effectiveIconBg = iconBackgroundColor ?? colorScheme.errorContainer;
    final Color effectiveConfirmBg = confirmBackgroundColor ?? colorScheme.error;
    final Color effectiveConfirmFg = confirmTextColor ?? colorScheme.onError;
    final Color effectiveCancelTextColor = cancelTextColor ?? colorScheme.onSurface;

    final dialogBg = theme.dialogTheme.backgroundColor ?? colorScheme.surface;
    final borderClr = theme.dividerColor.withValues(alpha: 0.5);
    final TextStyle? primaryButtonTextStyle = theme.textTheme.labelLarge?.copyWith(
      letterSpacing: 1.5,
      fontWeight: FontWeight.w700,
      color: effectiveConfirmFg,
    );
    final TextStyle? cancelButtonTextStyle = theme.textTheme.labelLarge?.copyWith(
      letterSpacing: 1.5,
      fontWeight: FontWeight.w600,
      color: effectiveCancelTextColor,
    );

    return Dialog(
      backgroundColor: dialogBg,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: borderClr),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: effectiveIconBg,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: effectiveIconColor, size: 24.sp),
            ),
            Gap(16.h),
            Text(
              title.toUpperCase(),
              style: theme.textTheme.titleLarge?.copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(12.h),
            content ?? Text(message ?? '', style: theme.textTheme.bodySmall?.copyWith(height: 1.4)),
            Gap(20.h),

            // Buttons: stacked vertical by default
            if (verticalButtons) ...[
              if (primaryOnTop) ...[
                if (confirmText != null) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: effectiveConfirmBg,
                        foregroundColor: effectiveConfirmFg,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      child: Text((confirmText)!.toUpperCase(), style: primaryButtonTextStyle),
                    ),
                  ),
                  Gap(12.h),
                ],

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderClr),
                      foregroundColor: effectiveCancelTextColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel?.call();
                    },
                    child: Text(cancelText.toUpperCase(), style: cancelButtonTextStyle),
                  ),
                ),
              ] else ...[
                // primary bottom
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderClr),
                      foregroundColor: effectiveCancelTextColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onCancel?.call();
                    },
                    child: Text(cancelText.toUpperCase(), style: cancelButtonTextStyle),
                  ),
                ),
                if (confirmText != null) ...[
                  Gap(12.h),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: effectiveConfirmBg,
                        foregroundColor: effectiveConfirmFg,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm?.call();
                      },
                      child: Text((confirmText)!.toUpperCase(), style: primaryButtonTextStyle),
                    ),
                  ),
                ],
              ],
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children:
                    actions ??
                    [
                      Text(
                        cancelText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: effectiveCancelTextColor,
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: effectiveConfirmBg,
                          foregroundColor: effectiveConfirmFg,
                          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm?.call();
                        },
                        child: confirmText != null
                            ? Text(confirmText!, style: primaryButtonTextStyle)
                            : null,
                      ),
                    ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

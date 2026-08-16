import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkup/core/errors/error_message_mapper.dart';

void showScaffoldMessage({
  required BuildContext context,
  required String message,
  Color? backgroundColor,
  Color? textColor,
  double fontSize = 16,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        sanitizeDisplayMessage(message),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: textColor ?? colorScheme.onError,
          fontSize: fontSize.sp,
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.error,
    ),
  );
}

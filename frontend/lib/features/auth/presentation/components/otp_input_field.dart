import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/shared_ui/constants/colors.dart';

class OtpInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool hasError;

  const OtpInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = hasError ? colorScheme.error : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label(context)?.copyWith(fontSize: 14.sp),
        ),
        Gap(6.h),
        TextField(
          obscureText: true,
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
            letterSpacing: 4.w,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            hintStyle: AppTextStyles.hint(context)?.copyWith(fontSize: 14.sp),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 14.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

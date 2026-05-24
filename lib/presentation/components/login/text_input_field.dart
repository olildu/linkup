import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:linkup/presentation/constants/colors.dart';

class TextInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback? toggleObscure;
  final bool hasError;

  const TextInputField({super.key, required this.label, required this.hintText, required this.controller, this.obscureText = false, this.toggleObscure, this.hasError = false});

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = widget.hasError ? colorScheme.error : colorScheme.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label(context)?.copyWith(fontSize: 16.sp),
        ),
        Gap(8.h),
        TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTextStyles.hint(context),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: widget.hasError ? colorScheme.error : colorScheme.primary),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            suffixIcon: widget.toggleObscure != null
                ? IconButton(
                    icon: Icon(
                      widget.obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.notSelected,
                    ),
                    onPressed: widget.toggleObscure,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
